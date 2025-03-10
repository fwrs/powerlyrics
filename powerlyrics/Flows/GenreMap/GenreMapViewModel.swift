//
//  GenreMapViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit

// MARK: - Constants

fileprivate extension Constants {
    
    static let minimumTotalValue: CGFloat = 0.0001
    
}

// MARK: - GenreMapViewModel

class GenreMapViewModel: ViewModel {
    
    // MARK: - DI
    
    let realmService: RealmServiceProtocol
    
    // MARK: - Observables
    
    let values = Observable(Constants.baseLikedSongCounts)
    
    let noData = Observable(false)
    
    // MARK: - Init
    
    init(realmService: RealmServiceProtocol) {
        self.realmService = realmService
    }
    
    // MARK: - Load data
    
    func loadData() {
        let total = (RealmLikedSongGenre.all.map { CGFloat(realmService.likedSongs(with: $0).count) } + [Constants.minimumTotalValue]).max().safe
        
        let counts = RealmLikedSongGenre.all.map { realmService.likedSongs(with: $0).count }
        
        if counts.filter({ $0 != 0 }).count < 2 {
            noData.value = true
            values.value = Constants.baseLikedSongCounts
        } else {
            noData.value = false
            values.value = RealmLikedSongGenre.all
                .map { CGFloat(realmService.likedSongs(with: $0).count) / total }
        }
    }
    
}
