//
//  RealmLikedSong.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/6/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import RealmSwift

// MARK: - Constants

extension Constants {
    
    static let unknownGenreID = 99
    
}

// MARK: - RealmLikedSong

class RealmLikedSong: Object {
    
    @objc private dynamic var genreInt = Constants.unknownGenreID
    
    @objc dynamic var geniusID = Int.zero
    @objc dynamic var name = String()
    @objc dynamic var thumbnailAlbumArtURL: String?
    @objc dynamic var albumArtURL: String?
    @objc dynamic var geniusURL: String?
    @objc dynamic var likeDate = Date()
    
    let artists = List<String>()
    
    var genre: RealmLikedSongGenre {
        get { RealmLikedSongGenre(rawValue: genreInt)! }
        set { genreInt = newValue.rawValue }
    }
    
}

extension RealmLikedSong {
    
    var asSharedSong: SharedSong {
        var albumArt: SharedImage?
        if let url = albumArtURL?.url {
            albumArt = .external(url)
        }
        
        var thumbnailAlbumArt: SharedImage?
        if let url = thumbnailAlbumArtURL?.url {
            thumbnailAlbumArt = .external(url)
        }
        
        return SharedSong(
            name: name,
            artists: Array(artists),
            albumArt: albumArt,
            thumbnailAlbumArt: thumbnailAlbumArt,
            geniusID: geniusID,
            geniusURL: geniusURL?.url
        )
    }
    
}
