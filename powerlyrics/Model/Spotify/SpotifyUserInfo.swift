//
//  SpotifyUserInfo.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/8/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Foundation

struct SpotifyUserInfo: Codable {
    struct ExplicitContentSettings: Codable {
        let filterEnabled: Bool
        let filterLocked: Bool
        
        private enum CodingKeys: String, CodingKey {
            case filterEnabled = "filter_enabled"
            case filterLocked = "filter_locked"
        }
    }
    
    enum Product: String, Codable {
        case premium
        case free
        case open
    }
    
    let id: String
    let uri: String
    
    let explicitContent: ExplicitContentSettings
    let displayName: String?
    let product: Product
    let images: [SharedImage]
    
    private enum CodingKeys: String, CodingKey {
        case id
        case uri
        case product
        case images
        
        case explicitContent = "explicit_content"
        case displayName = "display_name"
    }
}
