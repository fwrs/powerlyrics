//
//  RealmLikedSong.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/6/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Foundation
import RealmSwift

@objc enum RealmLikedSongGenre: Int, Codable, Equatable {
    case rock
    case classic
    case rap
    case country
    case acoustic
    case pop
    case jazz
    case edm
    
    case unknown = 99
}

extension RealmLikedSongGenre {
    var localizedName: String {
        switch self {
        case .rock:
            return "rock"
        case .classic:
            return "classic"
        case .rap:
            return "rap"
        case .country:
            return "country"
        case .acoustic:
            return "acoustic"
        case .pop:
            return "pop"
        case .jazz:
            return "jazz"
        case .edm:
            return "edm"
        case .unknown:
            return ":("
        }
        
    }
}

typealias DefaultRealmLikedSongGenreAction = (RealmLikedSongGenre) -> Void

class RealmLikedSong: Object {
    @objc private dynamic var genreInt = 99
    
    @objc dynamic var geniusID = 0
    @objc dynamic var name = ""
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
        if let url = self.albumArtURL?.url {
            albumArt = .external(url)
        }
        
        var thumbnailAlbumArt: SharedImage?
        if let url = self.thumbnailAlbumArtURL?.url {
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
