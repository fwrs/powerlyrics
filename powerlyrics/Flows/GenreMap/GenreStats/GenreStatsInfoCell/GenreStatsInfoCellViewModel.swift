//
//  GenreStatsInfoCellViewModel.swift
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

// MARK: - GenreStatsInfoLevel

enum GenreStatsInfoLevel {
    
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
            let songLikedText = count == 1 ?
                Strings.GenreAnalysis.Low.songsLikedSingular(count) :
                Strings.GenreAnalysis.Low.songsLikedPlural(count)
            
            return Strings.GenreAnalysis.low(genre.localizedName, songLikedText)
            
        case .ok:
            let songLikedText = count == 1 ?
                Strings.GenreAnalysis.Ok.songsLikedSingular(count) :
                Strings.GenreAnalysis.Ok.songsLikedPlural(count)
            
            return Strings.GenreAnalysis.ok(genre.localizedName, songLikedText)
            
        case .good:
            let likedSongText = count == 1 ?
                Strings.GenreAnalysis.Good.likedSongsSingular(count) :
                Strings.GenreAnalysis.Good.likedSongsPlural(count)
            
            return Strings.GenreAnalysis.good(likedSongText, genre.localizedName)
            
        case .overwhelming:
            return Strings.GenreAnalysis.overwhelming(genre.localizedName)
        }
    }
    
}

// MARK: - GenreStatsInfoCellViewModel

struct GenreStatsInfoCellViewModel: Equatable {
    
    let level: GenreStatsInfoLevel
    let count: Int
    let genre: RealmLikedSongGenre
    
}
