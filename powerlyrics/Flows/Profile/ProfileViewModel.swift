//
//  ProfileViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/31/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit
import RealmSwift

// MARK: - Constants

fileprivate extension Constants {
    
    static let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    
    static let year = DateFormatter().with {
        $0.dateFormat = "yyyy"
    }.string(from: Date())
    
    static let footerText = "Build \(buildNumber) — Powered by RapGenius \(year)"
    
    static let userPlaceholder = "Unknown user"
    
}

// MARK: - ProfileCell

enum ProfileCell: Equatable {
    case stats(StatsCellViewModel)
    case action(ActionCellViewModel)
    case build(BuildCellViewModel)
}

// MARK: - ProfileViewModel

class ProfileViewModel: ViewModel {
    
    // MARK: - DI
    
    let spotifyProvider: SpotifyProvider
    
    let realmService: RealmServiceProtocol
    
    let keychainService: KeychainServiceProtocol
    
    // MARK: - Observables
    
    let items = MutableObservableArray2D(Array2D<(), ProfileCell>(sectionsWithItems: [
        ((), [ProfileCell.stats(StatsCellViewModel())]),
        ((), [ProfileCell.action(ActionCellViewModel(action: .connectToSpotify)),
              ProfileCell.action(ActionCellViewModel(action: .likedSongs)),
              ProfileCell.action(ActionCellViewModel(action: .appSourceCode)),
              ProfileCell.action(ActionCellViewModel(action: .signOut))]),
        ((), [ProfileCell.build(BuildCellViewModel(text: Constants.footerText))])
    ]))
    
    let name = Observable(Constants.userPlaceholder)
    
    let premium = Observable(false)
    
    let avatar: Observable<SharedImage?> = Observable(nil)
    
    let fullAvatar: Observable<SharedImage?> = Observable(nil)
    
    let registerDate: Observable<Date?> = Observable(nil)
    
    let stats = Observable(StatsCellViewModel())
    
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
        name.value = userData?.name ?? Constants.userPlaceholder
        premium.value = userData?.premium ?? false
        registerDate.value = userData?.registerDate
        
        if keychainService.getDecodable(for: .spotifyAuthorizedWithAccount) == true {
            avatar.value = userData?.thumbnailAvatarURL?.url.map { .external($0) }
            fullAvatar.value = userData?.avatarURL?.url.map { .external($0) }
        } else {
            avatar.value = .local(Asset.Assets.nonSpotifyProfilePic.image)
            fullAvatar.value = .local(Asset.Assets.nonSpotifyProfilePic.image)
        }
        
        if let stats = realmService.stats {
            self.stats.value = StatsCellViewModel(likedSongs: realmService.likedSongsCount, searches: stats.searches, discoveries: stats.discoveries.count, viewedArtists: stats.viewedArtists.count)
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
    
    func resetAllViewControllers(window: UIWindow) {
        if let homeViewController = ((window.rootViewController as? UITabBarController)?.viewControllers?.first as? Router)?.viewControllers.first as? HomeViewController {
            homeViewController.viewModel.checkSpotifyAccount()
        }
        
        if let searchViewController = ((window.rootViewController as? UITabBarController)?.viewControllers?[safe: .one] as? Router)?.viewControllers.first as? SearchViewController {
            searchViewController.viewModel.reset()
        }
        
        if let genreMapViewController = ((window.rootViewController as? UITabBarController)?.viewControllers?[safe: .two] as? Router)?.viewControllers.first as? GenreMapViewController {
            genreMapViewController.reset()
        }
        
        for router in ((window.rootViewController as? UITabBarController)?.viewControllers) ?? [] {
            (router as? Router)?.popToRootViewController(animated: true)
        }
        
    }
    
}
