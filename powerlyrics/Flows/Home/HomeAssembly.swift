//
//  HomeAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Swinject

// MARK: - HomeScene

protocol HomeScene: ViewController {
    
    var flowSafari: DefaultURLAction? { get set }
    var flowLyrics: DefaultSharedSongPreviewAction? { get set }
    var flowSetup: DefaultSetupModeAction? { get set }
    var flowTrends: DefaultSharedSongListAction? { get set }
    var flowVirals: DefaultSharedSongListAction? { get set }
    
}

// MARK: - HomeAssembly

class HomeAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(HomeViewModel.self) { resolver in
            HomeViewModel(
                spotifyProvider: resolver.resolve(SpotifyProvider.self)!,
                realmService: resolver.resolve(RealmServiceProtocol.self)!,
                keychainService: resolver.resolve(KeychainServiceProtocol.self)!
            )
        }
        
        container.register(HomeScene.self) { resolver in
            let viewController = UIStoryboard.createController(HomeViewController.self)
            viewController.viewModel = resolver.resolve(HomeViewModel.self)
            return viewController
        }
        
    }
    
}
