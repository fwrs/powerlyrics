//
//  SpotifyAlbumSong.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/14/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

struct SpotifyAlbumSong: Codable, Equatable {
    
    let id: String
    let uri: String
    
    let artists: [SpotifyArtist]
    
    let explicit: Bool
    let name: String
    
}

extension SpotifyAlbumSong {
    
    func asSharedSong(with album: SpotifyAlbum) -> SharedSong {
        SharedSong(
            name: name,
            artists: artists.map(\.name),
            albumArt: album.albumArt,
            thumbnailAlbumArt: album.thumbnailAlbumArt,
            geniusID: nil,
            geniusURL: nil
        )
    }
    
}
