//
//  Album.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/23/20.
//

import Foundation

extension Spotify {

    struct Album: Codable, Equatable {
        
        let id: String
        let uri: String
        
        let artists: [Spotify.Artist]
        let images: [Shared.Image]
        let name: String
        
    }

}

extension Spotify.Album {
    
    var albumArt: Shared.Image? {
        images.first
    }
    
    var thumbnailAlbumArt: Shared.Image? {
        images[safe: images.count - 2] ?? images.last
    }
    
}
