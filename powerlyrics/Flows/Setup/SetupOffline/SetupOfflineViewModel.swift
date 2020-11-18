//
//  SetupOfflineViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import RealmSwift

class SetupOfflineViewModel: ViewModel {
    
    let spotifyProvider: SpotifyProvider
    
    let realmService: RealmServiceProtocol
    
    init(spotifyProvider: SpotifyProvider, realmService: RealmServiceProtocol) {
        self.spotifyProvider = spotifyProvider
        self.realmService = realmService
    }
    
    func saveLocalUserData(name: String, over18: Bool) {
        realmService.saveUserData(name: name.clean.typographized, over18: over18)
    }
    
    func fail() {
        realmService.unsetUserData()
    }
    
}
