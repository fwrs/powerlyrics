//
//  SpotifyPlaylistSong.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/27/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Foundation

struct SpotifyPlaylistSong: Codable, Equatable {
    
    let track: SpotifySong
    let isLocal: Bool
    
    private enum CodingKeys: String, CodingKey {
        case track
        
        case isLocal = "is_local"
    }
    
}

extension SpotifyPlaylistSong {
    
    var asSharedSong: SharedSong {
        track.asSharedSong
    }
    
}
