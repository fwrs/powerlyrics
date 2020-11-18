//
//  GeniusAlbum.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 16.11.20.
//

import Foundation

struct GeniusAlbum: Codable, Equatable {
    
    let fullTitle: String
    let name: String
    let id: Int
    
    enum CodingKeys: String, CodingKey {
        case fullTitle = "full_title"
        
        case name
        case id
    }
    
}
