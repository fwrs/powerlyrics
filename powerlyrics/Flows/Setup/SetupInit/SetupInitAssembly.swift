//
//  SetupInitAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//

import Swinject
import UIKit

class SetupInitAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(SetupInitViewModel.self) { _ in
            SetupInitViewModel()
        }
        
        container.register(SetupInitScene.self) { resolver in
            let viewController = UIStoryboard.createController(SetupInitViewController.self)
            viewController.viewModel = resolver.resolve(SetupInitViewModel.self)
            return viewController
        }
        
    }
    
}
