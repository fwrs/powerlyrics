//
//  SpotifySong.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//

import Foundation

struct SpotifySong: Codable, Equatable {
    
    let id: String
    let uri: String
    
    let album: SpotifyAlbum
    let artists: [SpotifyArtist]
    
    let explicit: Bool
    let name: String
    
}

extension SpotifySong {
    
    var asSharedSong: SharedSong {
        SharedSong(
            name: name,
            artists: artists.map(\.name),
            albumArt: album.albumArt,
            thumbnailAlbumArt: album.thumbnailAlbumArt,
            geniusURL: nil
        )
    }
    
}
