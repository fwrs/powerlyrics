//
//  Song.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/24/20.
//

import Foundation

extension Shared {
    
    struct Song: Codable, Equatable {
        var name: String
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
    
    var strippedFeatures: Shared.Song {
        var songName = name
        if let range = songName.range(of: "(feat.") {
            songName = String(songName[..<range.lowerBound]).clean
        }
        if let range = songName.range(of: "(with") {
            songName = String(songName[..<range.lowerBound]).clean
        }
        var selfCopy = self
        selfCopy.name = songName
        return selfCopy
    }
    
}

typealias DefaultSongAction = (Shared.Song) -> Void
