//
//  SetupInitialAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Swinject

// MARK: - SetupInitialScene

protocol SetupInitialScene: ViewController {
    
    var flowDismiss: DefaultAction? { get set }
    var flowSpotifyLogin: DefaultAction? { get set }
    var flowOfflineSetup: DefaultAction? { get set }
    
}

// MARK: - SetupInitialAssembly

class SetupInitialAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(SetupInitialScene.self) { resolver in
            let viewController = UIStoryboard.createController(SetupInitialViewController.self)
            viewController.viewModel = resolver.resolve(SetupSharedSpotifyViewModel.self)
            return viewController
        }
        
    }
    
}
