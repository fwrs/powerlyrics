//
//  GeniusSong.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/24/20.
//

import Foundation

struct GeniusSong: Codable, Equatable {
    
    let id: Int
    let url: URL?
    let title: String
    let primaryArtist: GeniusArtist
    
    let songArtImageURL: URL?
    let songArtImageThumbnailURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case primaryArtist = "primary_artist"
        case songArtImageURL = "song_art_image_url"
        case songArtImageThumbnailURL = "song_art_image_thumbnail_url"
        
        case id
        case url
        case title
    }
    
}

extension GeniusSong {
    
    var asSharedSong: SharedSong {
        
        var albumArt: SharedImage?
        
        if let url = songArtImageURL {
            albumArt = .external(url)
        } else if let url = songArtImageThumbnailURL {
            albumArt = .external(url)
        }
        
        var thumbnailAlbumArt: SharedImage?
        
        if let url = songArtImageThumbnailURL {
            thumbnailAlbumArt = .external(url)
        } else if let url = songArtImageURL {
            thumbnailAlbumArt = .external(url)
        }
        
        return SharedSong(
            name: title,
            artists: [primaryArtist.name],
            albumArt: albumArt,
            thumbnailAlbumArt: thumbnailAlbumArt,
            geniusID: id,
            geniusURL: url
        )
        
    }
    
}
