//
//  RealmLikedSongGenre.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/18/20.
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
            return Strings.Genre.rock
            
        case .classic:
            return Strings.Genre.classic
            
        case .rap:
            return Strings.Genre.rap
            
        case .country:
            return Strings.Genre.country
            
        case .acoustic:
            return Strings.Genre.acoustic
            
        case .pop:
            return Strings.Genre.pop
            
        case .jazz:
            return Strings.Genre.jazz
            
        case .edm:
            return Strings.Genre.edm
            
        case .unknown:
            return Strings.Genre.unknown
        }
        
    }
    
}

typealias DefaultRealmLikedSongGenreAction = (RealmLikedSongGenre) -> Void
