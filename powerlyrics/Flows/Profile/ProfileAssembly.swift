//
//  ProfileAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/31/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Swinject
import UIKit

protocol ProfileScene: ViewController {
    var flowLikedSongs: DefaultAction? { get set }
    var flowSetup: DefaultSetupModeAction? { get set }
}

class ProfileAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(ProfileViewModel.self) { resolver in
            ProfileViewModel(
                spotifyProvider: resolver.resolve(SpotifyProvider.self)!,
                realmService: resolver.resolve(RealmServiceProtocol.self)!
            )
        }
        
        container.register(ProfileScene.self) { resolver in
            let viewController = UIStoryboard.createController(ProfileViewController.self)
            viewController.viewModel = resolver.resolve(ProfileViewModel.self)
            return viewController
        }
        
    }
    
}
