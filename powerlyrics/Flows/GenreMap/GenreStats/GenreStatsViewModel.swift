//
//  GenreStatsViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/7/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit

// MARK: - GenreStatsCell

enum GenreStatsCell: Equatable {
    
    case empty
    case genreInfo(GenreStatsInfoCellViewModel)
    case song(SongCellViewModel, last: Bool = false)
    
}

// MARK: - GenreStatsViewModel

class GenreStatsViewModel: ViewModel {
    
    // MARK: - DI
    
    let realmService: RealmServiceProtocol
    
    // MARK: - Instance properties
    
    let genre: RealmLikedSongGenre
    
    // MARK: - Observables
    
    let items = MutableObservableArray<GenreStatsCell>()
    
    // MARK: - Init
    
    init(realmService: RealmServiceProtocol, genre: RealmLikedSongGenre) {
        self.realmService = realmService
        self.genre = genre
        
        super.init()
        
        loadData(initial: true)
    }
    
    // MARK: - Load data
    
    func loadData(initial: Bool = false) {
        let likedSongs = realmService.likedSongs(with: genre)
        let songs = likedSongs
            .enumerated()
            .map { index, item in
                GenreStatsCell.song(
                    SongCellViewModel(song: item.asSharedSong),
                    last: likedSongs.count - .one == index
                )
            }
        
        let counts = RealmLikedSongGenre.all.map { Float(realmService.likedSongs(with: $0).count) }
        let average = counts.reduce(.zero, +) / Float(counts.filter { $0 != .zero }.count)
        
        if songs.isEmpty {
            items.replace(with: [
                .empty
            ], performDiff: !initial)
        } else {
            items.replace(with: [
                .genreInfo(GenreStatsInfoCellViewModel(
                    level: .init(count: songs.count, average: average),
                    count: songs.count,
                    genre: genre
                ))
            ] + songs, performDiff: !initial)
        }
        isEmpty.value = songs.isEmpty
    }
    
}
