//
//  Album.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/23/20.
//

import Foundation

extension Spotify {

    struct Album: Codable, Equatable {
        
        let artists: [Spotify.Artist]
        let images: [Shared.Image]
        
    }

}
