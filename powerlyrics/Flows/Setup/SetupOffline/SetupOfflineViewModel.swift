//
//  SetupOfflineViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
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
