//
//  SongListLikedViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/20/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit

// MARK: - SongListLikedViewModel

class SongListLikedViewModel: SongListViewModel {

    // MARK: - Instance properties
    
    var firstLoad: Bool = true
    
    let today: Bool
    
    // MARK: - Init
    
    init(today: Bool, spotifyProvider: SpotifyProvider, realmService: RealmServiceProtocol) {
        self.today = today
        super.init(spotifyProvider: spotifyProvider, realmService: realmService)
    }
    
    // MARK: - Load data
    
    override func loadData(refresh: Bool = false, retry: Bool = false) {
        isFailed.value = false
        
        if refresh {
            startLoading(refresh)
        }
        
        let likedSongs = realmService.likedSongs()
        
        items.replace(
            with: likedSongs
                .filter { today ? Calendar.current.isDateInToday($0.likeDate) : true }
                .map {
                    .song(SongCellViewModel(
                        song: $0.asSharedSong
                    ))
                },
            performDiff: !firstLoad
        )
        
        firstLoad = false
        
        endLoading(refresh)
    }
    
}
