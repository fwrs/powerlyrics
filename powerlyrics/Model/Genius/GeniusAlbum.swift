//
//  GeniusAlbum.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/16/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
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
