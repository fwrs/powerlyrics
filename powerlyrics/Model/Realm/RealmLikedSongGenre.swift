//
//  RealmLikedSongGenre.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 18.11.20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import RealmSwift

// MARK: - Constants

fileprivate extension Constants {
    
    static let genreNamesMapping = [
        ["rock", "indie", "metal"],
        ["classic", "non-music", "literat"],
        ["trap", "rap", "r-b"],
        ["country"],
        ["acoustic"],
        ["pop"],
        ["jazz", "swing"],
        ["electr", "dance", "tranc", "ambien", "future bass"]
    ]
    
}

// MARK: - RealmLikedSongGenre

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
    
    init(_ string: String) {
        let genreInt = Constants.genreNamesMapping
            .firstIndex(where: { $0.contains { string.lowercased().contains($0) } == true }) ??
            Constants.unknownGenreID
        self = RealmLikedSongGenre(rawValue: genreInt) ?? .unknown
    }
    
    static var all: [RealmLikedSongGenre] {
        [.rock, .classic, .rap, .country, .acoustic, .pop, .jazz, .edm]
    }
    
    static var total: Int {
        all.count
    }

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
            return "unknown"
        }
        
    }
    
}

typealias DefaultRealmLikedSongGenreAction = (RealmLikedSongGenre) -> Void
