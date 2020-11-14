//
//  SpotifyAlbum.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/23/20.
//

import Foundation

struct SpotifyAlbum: Codable, Equatable {
    
    let id: String
    let uri: String
    
    let artists: [SpotifyArtist]
    let images: [SharedImage]
    let name: String
    
}

extension SpotifyAlbum {
    
    var albumArt: SharedImage? {
        images.first
    }
    
    var thumbnailAlbumArt: SharedImage? {
        images[safe: images.count - 2] ?? images.last
    }
    
}

typealias DefaultSpotifyAlbumAction = (SpotifyAlbum) -> Void
