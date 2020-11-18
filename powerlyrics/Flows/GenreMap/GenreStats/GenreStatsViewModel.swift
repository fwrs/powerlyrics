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
    
    let isEmpty = Observable(false)
    
    init(genre: RealmLikedSongGenre) {
        self.genre = genre
        super.init()
        reload()
    }
    
    func reload() {
        let songs = Realm.likedSongs(with: genre)
            .map { GenreStatsCell.song(SongCellViewModel(song: $0.asSharedSong)) }
        let counts = ([.rock, .classic, .rap, .country, .acoustic, .pop, .jazz, .edm]
                        .map { Float(Realm.likedSongs(with: $0).count) })
        let average = counts.reduce(0.0, +) / Float(counts.filter { $0 != 0 }.count)
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
        isEmpty.value = songs.isEmpty
    }
    
}
