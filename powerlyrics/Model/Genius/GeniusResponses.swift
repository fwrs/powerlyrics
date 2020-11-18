//
//  GeniusResponses.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/24/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Foundation

struct GeniusSearchResponse: Codable, Equatable {
    
    struct SearchResponseInner: Codable, Equatable {
        enum HitType: String, Codable, Equatable {
            case song
        }
        
        struct Hit: Codable, Equatable {
            let result: GeniusSong
            let type: HitType
        }
        
        let hits: [Hit]
    }
    
    let response: SearchResponseInner
    
}

struct GeniusSongResponse: Codable, Equatable {
    
    struct SongResponseInner: Codable, Equatable {
        let song: GeniusSong
    }
    
    let response: SongResponseInner
    
}
