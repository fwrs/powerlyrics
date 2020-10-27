//
//  SearchResponse.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/24/20.
//

import Foundation

extension Genius {
    
    struct SearchResponse: Codable, Equatable {
        struct SearchResponseInner: Codable, Equatable {
            enum HitType: String, Codable, Equatable {
                case song
            }
            
            struct Hit: Codable, Equatable {
                let result: Genius.Song
                let type: HitType
            }
            
            let hits: [Hit]
        }
        
        let response: SearchResponseInner
    }
    
}
