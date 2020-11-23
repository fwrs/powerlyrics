//
//  SharedSong.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/24/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Then

// MARK: - Constants

fileprivate extension Constants {
    
    static let featPrefix = "(feat."
    static let withPrefix = "(with"
    static let unknownArtistText = Strings.SongCell.unknownArtist
    
    static let maxArtists = 3
    
}

// MARK: - SharedSong

struct SharedSong: Codable, Equatable, Hashable, Then {
    
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
            Constants.unknownArtistText :
            artists.prefix(Constants.maxArtists).joined(separator: Constants.commaText) +
            (artists.count > Constants.maxArtists ? Constants.ellipsisText : Constants.emptyText)
    }
    
    var strippedFeatures: SharedSong {
        var songName = name
        if let range = songName.range(of: Constants.featPrefix) {
            songName = String(songName[..<range.lowerBound]).clean
        }
        if let range = songName.range(of: Constants.withPrefix) {
            songName = String(songName[..<range.lowerBound]).clean
        }
        var selfCopy = self
        selfCopy.name = songName
        return selfCopy
    }
    
}

// MARK: - Actions

typealias DefaultSharedSongAction = (SharedSong) -> Void
typealias DefaultSharedSongListAction = ([SharedSong]) -> Void
typealias DefaultSharedSongPreviewAction = (SharedSong, UIImage?) -> Void
