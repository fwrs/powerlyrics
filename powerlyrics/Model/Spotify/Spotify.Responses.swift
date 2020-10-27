//
//  PlayingContextResponse.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/23/20.
//

import Foundation

extension Spotify {
    
    struct PlayingContextResponse: Codable {
        let timestamp: Int
        let item: Song
    }
    
    struct PlaylistSongsResponse: Codable {
        let items: [PlaylistSong]
    }

}
