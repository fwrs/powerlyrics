//
//  GenreInfoCellViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/8/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

// MARK: - Constants

fileprivate extension Constants {
    
    static let okRange: Range<Float> = 0.2..<0.45
    static let goodRange: Range<Float> = 0.45..<0.8
    static let overwhelmingRange: PartialRangeFrom<Float> = 0.8...
    
}

// MARK: - GenreInfoLevel

enum GenreInfoLevel {
    
    case low
    case ok
    case good
    case overwhelming
    
    init(count: Int, average: Float) {
        if count == .one {
            self = .low
            return
        }
        if count < .three {
            self = .ok
            return
        }
        switch Float(count) / average {
        case Constants.okRange:
            self = .ok
        case Constants.goodRange:
            self = .good
        case Constants.overwhelmingRange:
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

// MARK: - GenreInfoCellViewModel

struct GenreInfoCellViewModel: Equatable {
    
    let level: GenreInfoLevel
    let count: Int
    let genre: RealmLikedSongGenre
    
}
