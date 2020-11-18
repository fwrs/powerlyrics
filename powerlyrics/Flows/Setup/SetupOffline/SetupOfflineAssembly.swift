//
//  SetupOfflineAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//

import Swinject
import UIKit

protocol SetupOfflineScene: ViewController {
    var flowDismiss: DefaultAction? { get set }
    var flowSpotifyLoginOffline: DefaultAction? { get set }
}

class SetupOfflineAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(SetupOfflineViewModel.self) { resolver in
            SetupOfflineViewModel(spotifyProvider: resolver.resolve(SpotifyProvider.self)!)
        }
        
        container.register(SetupOfflineScene.self) { resolver in
            let viewController = UIStoryboard.createController(SetupOfflineViewController.self)
            viewController.viewModel = resolver.resolve(SetupOfflineViewModel.self)
            return viewController
        }
        
    }
    
}
