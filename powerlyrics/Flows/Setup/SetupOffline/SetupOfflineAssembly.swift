//
//  SetupOfflineAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Swinject

// MARK: - SetupOfflineScene

protocol SetupOfflineScene: ViewController {
    var flowDismiss: DefaultAction? { get set }
    var flowSpotifyLoginOffline: DefaultAction? { get set }
}

// MARK: - SetupOfflineAssembly

class SetupOfflineAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(SetupOfflineViewModel.self) { resolver in
            SetupOfflineViewModel(
                spotifyProvider: resolver.resolve(SpotifyProvider.self)!,
                realmService: resolver.resolve(RealmServiceProtocol.self)!
            )
        }
        
        container.register(SetupOfflineScene.self) { resolver in
            let viewController = UIStoryboard.createController(SetupOfflineViewController.self)
            viewController.viewModel = resolver.resolve(SetupOfflineViewModel.self)
            return viewController
        }
        
    }
    
}
