//
//  SharedSong.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/24/20.
//

import Foundation

struct SharedSong: Codable, Equatable, Hashable {
    var name: String
    let artists: [String]
    
    let albumArt: SharedImage?
    let thumbnailAlbumArt: SharedImage?
    
    var geniusID: Int?
    var geniusURL: URL?
    var spotifyURL: URL?
}

extension SharedSong {
    
    var artistsString: String {
        artists.isEmpty ?
            "Unknown Artist" :
            artists.prefix(3).joined(separator: ", ") + (artists.count > 3 ? "..." : "")
    }
    
    var strippedFeatures: SharedSong {
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

typealias DefaultSharedSongAction = (SharedSong) -> Void
typealias DefaultSharedSongListAction = ([SharedSong]) -> Void
