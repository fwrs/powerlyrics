//
//  SpotifyResponses.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/23/20.
//

import Foundation

struct SpotifyPlayingContextResponse: Codable {
    let timestamp: Int
    let item: SpotifySong
}

struct SpotifyPlaylistSongsResponse: Codable {
    let items: [SpotifyPlaylistSong]
}

struct SpotifySearchAlbumsResponse: Codable {
    struct AlbumItems: Codable {
        let items: [SpotifyAlbum]
    }
    
    let albums: AlbumItems
}

struct SpotifyUserInfoResponse: Codable {
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
    
    private enum CodingKeys: String, CodingKey {
        case id
        case uri
        case product
        
        case explicitContent = "explicit_content"
        case displayName = "display_name"
    }
}
