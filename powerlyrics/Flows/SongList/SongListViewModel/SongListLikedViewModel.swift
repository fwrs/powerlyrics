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
    
    override var title: String {
        Constants.likedSongsTitle
    }
    
    var firstLoad: Bool = true
    
    // MARK: - Load data
    
    override func loadData(refresh: Bool = false, retry: Bool = false) {
        isFailed.value = false
        
        if refresh {
            startLoading(refresh)
        }
        
        let likedSongs = realmService.likedSongs()
        
        items.replace(with: likedSongs.map { .song(SongCellViewModel(
            song: $0.asSharedSong,
            accessory: .likeLogo
        )) }, performDiff: !firstLoad)
        
        firstLoad = false
        
        endLoading(refresh)
    }
    
}
