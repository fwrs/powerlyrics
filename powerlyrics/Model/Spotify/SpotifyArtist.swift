//
//  SpotifyArtist.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/23/20.
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
