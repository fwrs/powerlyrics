//
//  ProfileViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/31/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit

// MARK: - Constants

fileprivate extension Constants {
    
    static let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    static let footerText = Strings.Profile.build(buildNumber, year)

    static let year = DateFormatter().with {
        $0.dateFormat = "yyyy"
    }.string(from: Date())
    
}

// MARK: - ProfileCell

enum ProfileCell: Equatable {
    case stats(ProfileStatsCellViewModel)
    case action(ActionCellViewModel)
    case build(ProfileBuildCellViewModel)
}

// MARK: - ProfileViewModel

class ProfileViewModel: ViewModel {
    
    // MARK: - DI
    
    let spotifyProvider: SpotifyProvider
    
    let realmService: RealmServiceProtocol
    
    let keychainService: KeychainServiceProtocol
    
    // MARK: - Observables
    
    let items = MutableObservableArray2D(Array2D<(), ProfileCell>(sectionsWithItems: [
        ((), [ProfileCell.stats(ProfileStatsCellViewModel())]),
        ((), [ProfileCell.action(ActionCellViewModel(action: .connectToSpotify)),
              ProfileCell.action(ActionCellViewModel(action: .likedSongs)),
              ProfileCell.action(ActionCellViewModel(action: .appSourceCode)),
              ProfileCell.action(ActionCellViewModel(action: .signOut))]),
        ((), [ProfileCell.build(ProfileBuildCellViewModel(text: Constants.footerText))])
    ]))
    
    let name: Observable<String?> = Observable(nil)
    
    let premium = Observable(false)
    
    let avatar: Observable<SharedImage?> = Observable(nil)
    
    let avatarPreviewable: Observable<Bool> = Observable(false)
    
    let fullAvatar: Observable<SharedImage?> = Observable(nil)
    
    let registerDate: Observable<Date?> = Observable(nil)
    
    let stats = Observable(ProfileStatsCellViewModel())
    
    // MARK: - Init
    
    init(
        spotifyProvider: SpotifyProvider,
        realmService: RealmServiceProtocol,
        keychainService: KeychainServiceProtocol
    ) {
        self.spotifyProvider = spotifyProvider
        self.realmService = realmService
        self.keychainService = keychainService
        
        super.init()
        
        loadData()
    }
    
    // MARK: - Load data
    
    func loadData() {
        let userData = realmService.userData
        name.value = userData?.name
        premium.value = (userData?.premium).safe
        registerDate.value = userData?.registerDate
        
        if let thumbnailAvatarImage = userData?.thumbnailAvatarURL?.url.map({ SharedImage.external($0) }),
           let avatarImage = userData?.avatarURL?.url.map({ SharedImage.external($0) }) {
            avatar.value = thumbnailAvatarImage
            fullAvatar.value = avatarImage
            avatarPreviewable.value = true
        } else {
            avatar.value = .local(Asset.Assets.placeholderAvatar.image)
            fullAvatar.value = .local(Asset.Assets.placeholderAvatar.image)
            avatarPreviewable.value = false
        }
        
        if let stats = realmService.stats {
            self.stats.value = ProfileStatsCellViewModel(
                likedSongs: realmService.likedSongsCount,
                searches: stats.searches,
                discoveries: stats.discoveries.count,
                viewedArtists: stats.viewedArtists.count
            )
        }
        
        if items[sectionAt: .zero].items[.zero] != ProfileCell.stats(stats.value) {
            items[sectionAt: .zero].items[.zero] = ProfileCell.stats(stats.value)
        }
        
        let isSpotifyAccount: Bool? = keychainService.getDecodable(for: .spotifyAuthorizedWithAccount)
        
        if isSpotifyAccount == true, items[sectionAt: .one].items[.zero] !=
            ProfileCell.action(ActionCellViewModel(action: .manageAccount)) {
            items[sectionAt: .one].items[.zero] = ProfileCell.action(ActionCellViewModel(action: .manageAccount))
        } else if isSpotifyAccount != true,
                  items[sectionAt: .one].items[.zero] !=
                    ProfileCell.action(ActionCellViewModel(action: .connectToSpotify)) {
            items[sectionAt: .one].items[.zero] = ProfileCell.action(ActionCellViewModel(action: .connectToSpotify))
        }
        
    }
    
    // MARK: - Helper methods
    
    func logout() {
        spotifyProvider.logout()
        NotificationCenter.default.post(name: .appDidLogout, object: nil, userInfo: nil)
    }
    
}
