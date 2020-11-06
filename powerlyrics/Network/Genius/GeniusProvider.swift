//
//  GeniusProvider.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/24/20.
//

import Alamofire
import Moya
import SafariServices
import SwiftSoup
import Swinject
import UIKit

typealias GeniusProvider = MoyaProvider<Genius>

extension GeniusProvider {

    static func geniusAuthMiddleware() -> MoyaProvider<Target>.RequestClosure {
        { (endpoint, closure) in
            var request = try! endpoint.urlRequest()
            request.setValue("Bearer \(Tokens.Genius.accessToken)", forHTTPHeaderField: "Authorization")
            closure(.success(request))
        }
    }
    
    static func scrape(url: URL, completionHandler: DefaultLyricsAction?) {
        AF.request(url).response { response in
            guard let string = response.data?.string,
                  let doc: Document = try? SwiftSoup.parse(string),
                  let lyricsContainer = try? doc.select("div[class^='lyrics']"),
                  let _ = try? lyricsContainer.select("br").prepend("\\n"),
                  let text = try? lyricsContainer.text().replacingOccurrences(of: "\\n", with: "\n") else { return }
            
            let result = text.split(separator: "\n")
                .map(\.clean)
                .dedupNearby(equals: String())
                .reduce([Shared.LyricsSection(contents: .init())]) { result, element in
                    if element.starts(with: "[") || element.isEmpty {
                        return result + [Shared.LyricsSection(name: element, contents: .init())]
                    } else {
                        return result.enumerated().map {
                            Shared.LyricsSection(name: $1.name, contents: $0 + 1 == result.count ? $1.contents + [element] : $1.contents)
                        }
                    }
                }.filter { $0.contents.nonEmpty }
            
            completionHandler?(result)
        }
    }
        
}
