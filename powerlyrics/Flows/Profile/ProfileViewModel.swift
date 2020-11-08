//
//  ProfileViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/31/20.
//

import Bond
import ReactiveKit
import RealmSwift

class ProfileViewModel: ViewModel {
    
    let name = Observable("User")
    
    let premium = Observable(false)
    
    let registerDate = Observable(Date())
    
    init(spotifyProvider: SpotifyProvider) {
        self.spotifyProvider = spotifyProvider
        
        let userData = Realm.userData
        name.value = userData?.name ?? "User"
        premium.value = userData?.premium ?? false
        registerDate.value = userData?.registerDate ?? Date()
    }
    
    let spotifyProvider: SpotifyProvider
    
    let items = MutableObservableArray2D(Array2D<(), ProfileCell>(sectionsWithItems: [
        ((), [ProfileCell.stats(StatsCellViewModel())]),
        ((), [ProfileCell.action(ActionCellViewModel(action: .connectToSpotify)),
              ProfileCell.action(ActionCellViewModel(action: .manageAccount)),
              ProfileCell.action(ActionCellViewModel(action: .likedSongs)),
              ProfileCell.action(ActionCellViewModel(action: .signOut))]),
        ((), [ProfileCell.build(BuildCellViewModel(text: "Build 4837. Powered by RapGenius 2020"))])
    ]))
    
}
