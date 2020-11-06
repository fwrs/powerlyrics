//
//  Song.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//

import Foundation

extension Spotify {

    struct Song: Codable, Equatable {
        
        let id: String
        let uri: String
        
        let album: Spotify.Album
        let artists: [Spotify.Artist]
        
        let explicit: Bool
        let name: String
        
    }

}

extension Spotify.Song {
    
    var asSharedSong: Shared.Song {
        Shared.Song(
            name: name,
            artists: artists.map(\.name),
            albumArt: album.albumArt,
            thumbnailAlbumArt: album.thumbnailAlbumArt,
            geniusURL: nil
        )
    }
    
}
