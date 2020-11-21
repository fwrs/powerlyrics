//
//  SongListViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/14/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit

// MARK: - Constants

extension Constants {
    
    static let trendingTitle = "trending"
    static let viralTitle = "viral"
    static let likedSongsTitle = "liked songs"
    
}

// MARK: - SongListCell

enum SongListCell: Equatable {
    case song(SongCellViewModel)
    case loading
}

// MARK: - SongListViewModel

class SongListViewModel: ViewModel {
    
    // MARK: - DI

    let spotifyProvider: SpotifyProvider
    
    let realmService: RealmServiceProtocol
    
    // MARK: - Instance properties
    
    var title: String {
        fatalError("Must be overriden")
    }
    
    // MARK: - Observables
    
    let items = MutableObservableArray<SongListCell>()
    
    let isLoadingWithPreview = Observable(false)
    
    // MARK: - Init
    
    init(spotifyProvider: SpotifyProvider, realmService: RealmServiceProtocol) {
        self.spotifyProvider = spotifyProvider
        self.realmService = realmService
        
        super.init()
    }
    
    // MARK: - Load data
    
    func loadData(refresh: Bool = false, retry: Bool = false) {
        fatalError("Must be overriden")
    }
    
}
