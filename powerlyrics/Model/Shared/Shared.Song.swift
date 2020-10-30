//
//  Song.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/24/20.
//

import Foundation

extension Shared {
    
    struct Song: Codable, Equatable {
        let name: String
        let artists: [String]
        
        let albumArt: Image?
        let thumbnailAlbumArt: Image?
        
        let geniusURL: URL?
    }
    
}

extension Shared.Song {
    
    var artistsString: String {
        artists.isEmpty ?
            "Unknown Artist" :
            artists.prefix(3).joined(separator: ", ") + (artists.count > 3 ? "..." : "")
    }
    
}

typealias DefaultSongAction = (Shared.Song) -> Void
