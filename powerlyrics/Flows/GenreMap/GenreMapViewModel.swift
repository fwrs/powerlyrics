//
//  GenreMapViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit
import RealmSwift

class GenreMapViewModel: ViewModel {
    
    let realmService: RealmServiceProtocol
    
    let noData = Observable(false)
    
    let values = Observable(Constants.baseLikedSongCounts)
    
    init(realmService: RealmServiceProtocol) {
        self.realmService = realmService
    }
    
    func loadData() {
        let total = (RealmLikedSongGenre.all.map { CGFloat(realmService.likedSongs(with: $0).count) } + [0.0001]).max().safe
        
        let counts = [realmService.likedSongs(with: .rock).count,
                      realmService.likedSongs(with: .classic).count,
                      realmService.likedSongs(with: .rap).count,
                      realmService.likedSongs(with: .country).count,
                      realmService.likedSongs(with: .acoustic).count,
                      realmService.likedSongs(with: .pop).count,
                      realmService.likedSongs(with: .jazz).count,
                      realmService.likedSongs(with: .edm).count]

        if counts.filter({ $0 != .zero }).count < .two {
            noData.value = true
            values.value = Constants.baseLikedSongCounts
        } else {
            noData.value = false
            values.value = RealmLikedSongGenre.all.map { max(0.012, CGFloat(realmService.likedSongs(with: $0).count) / total) }
        }
    }
    
}
