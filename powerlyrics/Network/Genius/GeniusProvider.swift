//
//  GeniusProvider.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/24/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Alamofire
import Moya
import SafariServices
import SwiftSoup
import Swinject

typealias GeniusProvider = MoyaProvider<Genius>

extension GeniusProvider {

    static func geniusAuthMiddleware() -> MoyaProvider<Target>.RequestClosure {
        { (endpoint, closure) in
            var request = try! endpoint.urlRequest()
            request.setValue("Bearer \(Tokens.Genius.accessToken)", forHTTPHeaderField: "Authorization")
            closure(.success(request))
        }
    }
    
    static func scrape(url: URL, completionHandler: DefaultLyricsResultAction?, failureHandler: DefaultAction?) {
        AF.request(url).response { response in
            if case .failure = response.result {
                failureHandler?()
                return
            }
            guard let string = response.data?.string,
                  let doc: Document = try? SwiftSoup.parse(string),
                  let lyricsContainer = try? doc.select("div[class^='lyrics']"),
                  let _ = try? lyricsContainer.select("br").prepend("\\n"),
                  let text = try? lyricsContainer.text().replacingOccurrences(of: "\\n", with: "\n") else { return }
            
            // MARK: - Lyrics parsing
            
            let result1 = text.split(separator: "\n").map(\.clean).joined(separator: "\n").split(separator: "]").map { $0.starts(with: "\n") ? $0 : "\n\($0)" }.joined(separator: "]").components(separatedBy: "\n").map(\.clean)
            let result2 = result1.first?.isEmpty == true ? Array(result1.dropFirst()) : result1
            let result3 = result2.last?.isEmpty == true ? Array(result2.dropLast()) : result2
            
            let lyrics = result3
                .dedupNearby(equals: String())
                .reduce([Shared.LyricsSection(contents: .init())]) { result, element in
                    if element.starts(with: "[") || element.isEmpty {
                        return result + [Shared.LyricsSection(name: element.isEmpty ? nil : element, contents: .init())]
                    } else {
                        return result.enumerated().map {
                            Shared.LyricsSection(name: $1.name, contents: $0 + 1 == result.count ? $1.contents + [element] : $1.contents)
                        }
                    }
                }.filter { $0.contents.nonEmpty || ($0.name?.nonEmpty).safe }
            
            // MARK: - Genre parsing
            
            var genre: RealmLikedSongGenre = .unknown
            let genreNames = [["rock", "indie", "metal"],
                              ["classic", "non-music", "literat"],
                              ["trap", "rap", "r-b"],
                              ["country"],
                              ["acoustic"],
                              ["pop"],
                              ["jazz", "swing"],
                              ["electr", "dance", "tranc", "ambien", "future bass"]]
            let content = (try? doc.outerHtml()).safe.components(separatedBy: "\\\"songRelationships\\\"").first.safe
            let genreRegEx = try! NSRegularExpression(pattern: "genius\\.com\\/tags\\/(.*?)(&quot;|\\\")")
            if let genreRange = genreRegEx.matches(in: content, options: [], range: NSRange(location: 0, length: content.count)).max(by: { $0.range.location < $1.range.location })?.range {
                if let genreText = NSString(string: content).substring(with: genreRange).components(separatedBy: "&quot;").first?.components(separatedBy: "/").last,
                   let genreInt = genreNames.firstIndex(where: { $0.contains { genreText.lowercased().contains($0) } == true }) {
                    genre = RealmLikedSongGenre(rawValue: genreInt) ?? .unknown
                }
            }

            completionHandler?(Shared.LyricsResult(lyrics: lyrics, genre: genre))
        }
    }
        
}
