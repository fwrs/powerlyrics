//
//  SetupOfflineViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Foundation
import RealmSwift

class SetupOfflineViewModel: ViewModel {
    
    let spotifyProvider: SpotifyProvider
    
    init(spotifyProvider: SpotifyProvider) {
        self.spotifyProvider = spotifyProvider
    }
    
    func saveLocalUserData(name: String, over18: Bool) {
        Realm.saveUserData(name: name.clean.typographized, over18: over18)
    }
    
    func fail() {
        Realm.unsetUserData()
    }
    
}
