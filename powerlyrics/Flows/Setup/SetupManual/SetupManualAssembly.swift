//
//  SetupManualAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//

import Swinject
import UIKit

protocol SetupManualScene: ViewController {
    var flowDismiss: DefaultAction? { get set }
}

class SetupManualAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(SetupManualViewModel.self) { _ in
            SetupManualViewModel()
        }
        
        container.register(SetupManualScene.self) { resolver in
            let viewController = UIStoryboard.createController(SetupManualViewController.self)
            viewController.viewModel = resolver.resolve(SetupManualViewModel.self)
            return viewController
        }
        
    }
    
}
