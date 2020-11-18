//
//  GenreStatsViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/7/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
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
    
    let realmService: RealmServiceProtocol
    
    let items = MutableObservableArray<GenreStatsCell>()
    
    let genre: RealmLikedSongGenre
    
    let isEmpty = Observable(false)
    
    init(realmService: RealmServiceProtocol, genre: RealmLikedSongGenre) {
        self.realmService = realmService
        self.genre = genre
        super.init()
        reload()
    }
    
    func reload() {
        let songs = realmService.likedSongs(with: genre)
            .map { GenreStatsCell.song(SongCellViewModel(song: $0.asSharedSong)) }
        let counts = RealmLikedSongGenre.all.map { Float(realmService.likedSongs(with: $0).count) }
        let average = counts.reduce(.zero, +) / Float(counts.filter { $0 != .zero }.count)
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
