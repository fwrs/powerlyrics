//
//  HomeAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Swinject
import UIKit

class HomeAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(HomeViewModel.self) { _ in
            HomeViewModel()
        }
        
        container.register(HomeScene.self) { resolver in
            let viewController = UIStoryboard.createController(HomeViewController.self)
            viewController.viewModel = resolver.resolve(HomeViewModel.self)
            return viewController
        }
        
    }
    
}
