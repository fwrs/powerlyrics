//
//  SpotifyPlaylistSong.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/27/20.
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
