//
//  ProfileAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/31/20.
//

import Swinject
import UIKit

protocol ProfileScene: ViewController {
    var flowLikedSongs: DefaultAction? { get set }
}

class ProfileAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(ProfileViewModel.self) { resolver in
            ProfileViewModel(spotifyProvider: resolver.resolve(SpotifyProvider.self)!)
        }
        
        container.register(ProfileScene.self) { resolver in
            let viewController = UIStoryboard.createController(ProfileViewController.self)
            viewController.viewModel = resolver.resolve(ProfileViewModel.self)
            return viewController
        }
        
    }
    
}
