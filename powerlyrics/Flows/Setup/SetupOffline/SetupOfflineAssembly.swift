//
//  SetupOfflineAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//

import Swinject
import UIKit

class SetupOfflineAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(SetupOfflineViewModel.self) { _ in
            SetupOfflineViewModel()
        }
        
        container.register(SetupOfflineScene.self) { resolver in
            let viewController = UIStoryboard.createController(SetupOfflineViewController.self)
            viewController.viewModel = resolver.resolve(SetupOfflineViewModel.self)
            return viewController
        }
        
    }
    
}
