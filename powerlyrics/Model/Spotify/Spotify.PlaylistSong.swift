//
//  Spotify.PlaylistSong.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/27/20.
//

import Foundation

extension Spotify {

    struct PlaylistSong: Codable, Equatable {
        
        let track: Song
        let isLocal: Bool
        
        private enum CodingKeys: String, CodingKey {
            case track
            
            case isLocal = "is_local"
        }
        
    }

}

extension Spotify.PlaylistSong {
    
    var asSharedSong: Shared.Song {
        track.asSharedSong
    }
    
}
