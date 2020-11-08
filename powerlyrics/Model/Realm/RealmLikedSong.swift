//
//  RealmLikedSong.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/6/20.
//

import Foundation
import RealmSwift

@objc enum LikedSongGenre: Int, Codable, Equatable {
    case rock
    case classic
    case rap
    case country
    case acoustic
    case pop
    case jazz
    case edm
    
    case unknown
}

typealias DefaultLikedSongGenreAction = (LikedSongGenre) -> Void

class RealmLikedSong: Object {
    @objc private dynamic var genreInt = 0
    
    @objc dynamic var name = ""
    @objc dynamic var albumArtURL: String?
    @objc dynamic var geniusURL: String?
    
    let artists = List<String>()
    
    var genre: LikedSongGenre {
        get { LikedSongGenre(rawValue: genreInt)! }
        set { genreInt = newValue.rawValue }
    }
}
