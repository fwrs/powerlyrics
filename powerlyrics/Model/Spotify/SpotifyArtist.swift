//
//  SpotifyArtist.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/23/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Foundation

struct SpotifyArtist: Codable, Equatable {
    
    let id: String
    let uri: String
    
    let name: String
    
}

struct SpotifyFullArtist: Codable, Equatable {
    
    let id: String
    let uri: String
    
    let name: String
    let genres: [String]
    let images: [SharedImage]
    let popularity: Int
    
}
