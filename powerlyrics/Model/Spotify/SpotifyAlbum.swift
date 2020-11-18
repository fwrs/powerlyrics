//
//  SpotifyAlbum.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/23/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

// MARK: - Constants

fileprivate extension Constants {
    
    static let secondToLast = 2
    
}

// MARK: - SpotifyAlbum

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
        images[safe: images.count - Constants.secondToLast] ?? images.last
    }
    
}

typealias DefaultSpotifyAlbumAction = (SpotifyAlbum) -> Void
