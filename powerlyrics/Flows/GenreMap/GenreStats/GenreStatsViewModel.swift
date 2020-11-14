//
//  GenreStatsViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/7/20.
//

import Bond
import ReactiveKit
import RealmSwift

enum GenreStatsCell: Equatable {
    case song(SongCellViewModel)
    case genreInfo(GenreInfoCellViewModel)
    case empty
}

class GenreStatsViewModel: ViewModel {
    
    let items = MutableObservableArray<GenreStatsCell>()
    
    let genre: RealmLikedSongGenre
    
    let isEmpty: Bool
    
    init(genre: RealmLikedSongGenre) {
        self.genre = genre
        let songs = Realm.likedSongs(with: genre)
            .map { GenreStatsCell.song(SongCellViewModel(song: $0.asSharedSong)) }
        self.isEmpty = songs.isEmpty
        super.init()
        let average = ([.rock, .classic, .rap, .country, .acoustic, .pop, .jazz, .edm]
                    .map { Float(Realm.likedSongs(with: $0).count) }).reduce(0.0, +) / Float(Realm.likedSongsCount)
        if songs.isEmpty {
            items.replace(with: [
                .empty
            ], performDiff: true)
        } else {
            items.replace(with: [
                .genreInfo(GenreInfoCellViewModel(
                    level: .init(count: songs.count, average: average),
                    count: songs.count,
                    genre: genre
                ))
            ] + songs, performDiff: true)
        }
    }
    
}
