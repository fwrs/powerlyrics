//
//  ProfileAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/31/20.
//

import Swinject
import UIKit

protocol ProfileScene: ViewController {}

class ProfileAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(ProfileViewModel.self) { _ in
            ProfileViewModel()
        }
        
        container.register(ProfileScene.self) { resolver in
            let viewController = UIStoryboard.createController(ProfileViewController.self)
            viewController.viewModel = resolver.resolve(ProfileViewModel.self)
            return viewController
        }
        
    }
    
}
