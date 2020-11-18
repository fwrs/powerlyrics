//
//  SpotifySong.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//

import Foundation

struct SpotifySong: Codable, Equatable {
    
    let id: String
    let uri: String
    
    let album: SpotifyAlbum
    let artists: [SpotifyArtist]
    
    let explicit: Bool
    let name: String
    
    let externalURLs: [String: URL?]?
    
    enum CodingKeys: String, CodingKey {
        case externalURLs = "external_urls"
        
        case id
        case uri
        case album
        case artists
        case explicit
        case name
    }
    
}

extension SpotifySong {
    
    var asSharedSong: SharedSong {
        let spotifyURL = externalURLs?["spotify"]?.flatMap { $0 }
        return SharedSong(
            name: name,
            artists: artists.map(\.name),
            albumArt: album.albumArt,
            thumbnailAlbumArt: album.thumbnailAlbumArt,
            geniusID: nil,
            geniusURL: nil,
            spotifyURL: spotifyURL
        )
    }
    
}
