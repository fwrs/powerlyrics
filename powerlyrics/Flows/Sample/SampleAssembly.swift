//
//  SampleAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Swinject
import UIKit

class SampleAssembly: Assembly {

    override func assemble(container: Container) {
        container.register(SampleViewModel.self) { _ in
            SampleViewModel()
        }
        
        container.register(SampleScene.self) { resolver in
            let viewController = UIStoryboard.createController(SampleViewController.self)
            viewController.viewModel = resolver.resolve(SampleViewModel.self)
            return viewController
        }
    }
    
}
