//
//  Song.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/24/20.
//

import Foundation

extension Genius {
    
    struct Song: Codable, Equatable {
        
        let id: Int
        let url: URL?
        let title: String
        let primaryArtist: Genius.Artist
        
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
    
}

extension Genius.Song {
    
    var asSharedSong: Shared.Song {
        
        var albumArt: Shared.Image?
        
        if let url = songArtImageURL {
            albumArt = .external(url)
        } else if let url = songArtImageThumbnailURL {
            albumArt = .external(url)
        }
        
        var thumbnailAlbumArt: Shared.Image?
        
        if let url = songArtImageThumbnailURL {
            thumbnailAlbumArt = .external(url)
        } else if let url = songArtImageURL {
            thumbnailAlbumArt = .external(url)
        }
        
        return Shared.Song(
            name: title,
            artists: [primaryArtist.name],
            albumArt: albumArt,
            thumbnailAlbumArt: thumbnailAlbumArt,
            geniusURL: url
        )
        
    }
    
}
