//
//  Local.LikedSong.swift
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

extension Local {
    
    class LikedSong: Object {
        @objc dynamic var name = ""
        @objc dynamic var artists = [String]()
        @objc dynamic var genre = LikedSongGenre.unknown
        @objc dynamic var albumArtURL: String?
        @objc dynamic var geniusURL: URL?
    }
    
}
