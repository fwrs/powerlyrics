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
    
    let avatar: Observable<SharedImage?> = Observable(nil)
    
    let fullAvatar: Observable<SharedImage?> = Observable(nil)
    
    let registerDate: Observable<Date?> = Observable(nil)
    
    let stats = Observable(StatsCellViewModel())
    
    init(spotifyProvider: SpotifyProvider) {
        self.spotifyProvider = spotifyProvider
        super.init()
        updateData()
    }
    
    func updateData() {
        let userData = Realm.userData
        name.value = userData?.name ?? "User"
        premium.value = userData?.premium ?? false
        registerDate.value = userData?.registerDate
        if Config.getResolver().resolve(KeychainStorageProtocol.self)!.getDecodable(for: .spotifyAuthorizedWithAccount) == true {
            avatar.value = userData?.thumbnailAvatarURL?.url.map { .external($0) }
            fullAvatar.value = userData?.avatarURL?.url.map { .external($0) }
        } else {
            avatar.value = .local(Asset.Assets.nonSpotifyProfilePic.image)
            fullAvatar.value = .local(Asset.Assets.nonSpotifyProfilePic.image)
        }
        if let stats = Realm.stats {
            self.stats.value = StatsCellViewModel(likedSongs: Realm.likedSongsCount, searches: stats.searches, discoveries: stats.discoveries.count, viewedArtists: stats.viewedArtists.count)
        }
        if items[sectionAt: 0].items[0] != ProfileCell.stats(stats.value) {
            items[sectionAt: 0].items[0] = ProfileCell.stats(stats.value)
        }
        let isSpotifyAccount: Bool? = (Config.getResolver().resolve(KeychainStorageProtocol.self)!.getDecodable(for: .spotifyAuthorizedWithAccount) as Bool?)
        if isSpotifyAccount == true, items[sectionAt: 1].items[0] !=
            ProfileCell.action(ActionCellViewModel(action: .manageAccount)) {
            items[sectionAt: 1].items[0] = ProfileCell.action(ActionCellViewModel(action: .manageAccount))
        } else if isSpotifyAccount != true, items[sectionAt: 1].items[0] != ProfileCell.action(ActionCellViewModel(action: .connectToSpotify)) {
            items[sectionAt: 1].items[0] = ProfileCell.action(ActionCellViewModel(action: .connectToSpotify))
        }
    }
    
    let spotifyProvider: SpotifyProvider
    
    let items = MutableObservableArray2D(Array2D<(), ProfileCell>(sectionsWithItems: [
        ((), [ProfileCell.stats(StatsCellViewModel())]),
        ((), [ProfileCell.action(ActionCellViewModel(action: .connectToSpotify)),
              ProfileCell.action(ActionCellViewModel(action: .likedSongs)),
              ProfileCell.action(ActionCellViewModel(action: .appSourceCode)),
              ProfileCell.action(ActionCellViewModel(action: .signOut))]),
        ((), [ProfileCell.build(BuildCellViewModel(text: "Build 4837. Powered by RapGenius 2020"))])
    ]))
    
}
