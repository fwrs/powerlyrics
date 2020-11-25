//
//  GeniusProvider.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/24/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Alamofire
import Moya
import SwiftSoup
import Swinject

// MARK: - Constants

extension Constants {
    
    static let sectionBegin: Character = "["
    static let sectionEnd: Character = "]"
    static let instrumentalSystemMessage = "This song is an instrumental"
    static let instrumentalSystemMessage2 = "instrumental"
    static let instrumentalResponse = Strings.Lyrics.instrumentalContent
    
}

fileprivate extension Constants {
    
    static let genreRegEx = try! NSRegularExpression(pattern: "genius\\.com\\/tags\\/(.*?)(&quot;|\\\")")
    
    static let bearerToken = "Bearer"
    static let authorizationHeader = "Authorization"
    static let lyricsWrapperSelector = "div[class^='lyrics']"
    static let brSelector = "br"
    static let tagTypeSeparator = "\\\"songRelationships\\\""
    static let htmlEscapedQuoteMark = "&quot;"
    static let urlSeparator = "/"
    
}

// MARK: - GeniusProvider

typealias GeniusProvider = MoyaProvider<Genius>

extension GeniusProvider {

    static func geniusAuthMiddleware() -> MoyaProvider<Target>.RequestClosure {
        { (endpoint, closure) in
            var request = try! endpoint.urlRequest()
            request.setValue(
                "\(Constants.bearerToken) \(Tokens.Genius.accessToken)",
                forHTTPHeaderField: Constants.authorizationHeader
            )
            closure(.success(request))
        }
    }
    
    static func scrape(url: URL, completionHandler: DefaultSharedLyricsResultAction?, failureHandler: DefaultAction?) {
        AF.request(url).response { response in
            if case .failure = response.result {
                failureHandler?()
                return
            }
            guard let string = response.data?.string,
                  let doc: Document = try? SwiftSoup.parse(string),
                  let lyricsContainer = try? doc.select(Constants.lyricsWrapperSelector),
                  let _ = try? lyricsContainer.select(Constants.brSelector).prepend(Constants.escapedNewline),
                  let text = try? lyricsContainer.text()
                    .replacingOccurrences(of: Constants.escapedNewline, with: Constants.newline) else { return }
            
            // MARK: - Lyrics parsing
            
            let result1 = (
                text.contains(Constants.instrumentalSystemMessage) ||
                    text.clean.lowercased() == Constants.instrumentalSystemMessage2
            ) ? [Constants.instrumentalResponse] : text
                .split(separator: Constants.newlineCharacter)
                .map(\.clean)
                .joined(separator: String(Constants.newline))
                .split(separator: Constants.sectionEnd)
                .map { $0.starts(with: String(Constants.newline)) ? $0 : "\(Constants.newline)\($0)" }
                .joined(separator: String(Constants.sectionEnd))
                .components(separatedBy: String(Constants.newline))
                .map(\.clean)
            
            let result2 = result1.first?.isEmpty == true ? Array(result1.dropFirst()) : result1
            let result3 = result2.last?.isEmpty == true ? Array(result2.dropLast()) : result2
            
            let lyrics = result3
                .dedupNearby(equals: String(Constants.newline))
                .reduce([SharedLyricsSection(contents: .init())]) { result, element in
                    if element.starts(with: String(Constants.sectionBegin)) || element.isEmpty {
                        return result + [SharedLyricsSection(name: element.isEmpty ? nil : element, contents: .init())]
                    } else {
                        return result.enumerated().map {
                            SharedLyricsSection(
                                name: $1.name,
                                contents: $0 + .one == result.count ? $1.contents + [element] : $1.contents
                            )
                        }
                    }
                }.filter { $0.contents.nonEmpty || ($0.name?.nonEmpty).safe }
            
            // MARK: - Genre parsing
            
            var genre: RealmLikedSongGenre = .unknown
            
            let content = (try? doc.outerHtml()).safe.components(separatedBy: Constants.tagTypeSeparator).first.safe
            
            if let genreRange = Constants.genreRegEx.matches(
                in: content,
                options: [],
                range: NSRange(location: .zero, length: content.count)
            ).max(by: { $0.range.location < $1.range.location })?.range {
                if let genreText = NSString(string: content)
                    .substring(with: genreRange)
                    .components(separatedBy: Constants.htmlEscapedQuoteMark)
                    .first?
                    .components(separatedBy: Constants.urlSeparator)
                    .last {
                    genre = RealmLikedSongGenre(genreText)
                }
            }

            completionHandler?(SharedLyricsResult(lyrics: lyrics, genre: genre))
        }
    }
        
}
