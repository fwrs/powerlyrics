//
//  GenreInfoCellViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/8/20.
//

import Foundation

enum GenreInfoLevel {
    case low          //  0% ≤ count / avg <  20%
    case ok           // 20% ≤ count / avg <  45%
    case good         // 45% ≤ count / avg <  80%
    case overwhelming // 80% ≤ count / avg < 100%
    
    init(count: Int, average: Float) {
        if count == 1 {
            self = .low
            return
        }
        if count < 3 {
            self = .ok
            return
        }
        switch Float(count) / average {
        case 0.2..<0.45:
            self = .ok
        case 0.45..<0.8:
            self = .good
        case 0.8...:
            self = .overwhelming
        default:
            self = .low
        }
    }
    
    var emoji: String {
        switch self {
        case .low:
            return "🐣"
        case .ok:
            return "🙂"
        case .good:
            return "👍"
        case .overwhelming:
            return "💛"
        }
    }
    
    func localizedDescription(count: Int, genre: RealmLikedSongGenre) -> String {
        switch self {
        case .low:
            return "You appear to enjoy \(genre.localizedName) less than others, since you have just \(count) song\(count.sIfNotOne) liked from it."
        case .ok:
            return "Looks like you have some interest in \(genre.localizedName), with total of \(count) song\(count.sIfNotOne) liked."
        case .good:
            return "Having liked \(count) song\(count.sIfNotOne)s from \(genre.localizedName), looks like you’re a fan of it!"
        case .overwhelming:
            return "Looks like you’re a huge fan of \(genre.localizedName), maybe try exploring some other genres."
        }
    }
}

struct GenreInfoCellViewModel: Equatable {
    let level: GenreInfoLevel
    let count: Int
    let genre: RealmLikedSongGenre
}
