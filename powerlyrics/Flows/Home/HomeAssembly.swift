//
//  HomeAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Swinject
import UIKit

protocol HomeScene: ViewController {
    var flowLyrics: ((SharedSong, UIImage?) -> Void)? { get set }
    var flowSetup: DefaultSetupModeAction? { get set }
    var flowTrends: DefaultSharedSongListAction? { get set }
    var flowVirals: DefaultSharedSongListAction? { get set }
}

class HomeAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(HomeViewModel.self) { resolver in
            HomeViewModel(spotifyProvider: resolver.resolve(SpotifyProvider.self)!)
        }
        
        container.register(HomeScene.self) { resolver in
            let viewController = UIStoryboard.createController(HomeViewController.self)
            viewController.viewModel = resolver.resolve(HomeViewModel.self)
            return viewController
        }
        
    }
    
}
