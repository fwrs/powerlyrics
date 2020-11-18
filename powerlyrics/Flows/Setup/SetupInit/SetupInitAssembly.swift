//
//  SetupInitAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Swinject
import UIKit

// MARK: - SetupInitScene

protocol SetupInitScene: ViewController {
    
    var flowDismiss: DefaultAction? { get set }
    var flowSpotifyLogin: DefaultAction? { get set }
    var flowOfflineSetup: DefaultAction? { get set }
    
}

// MARK: - SetupInitAssembly

class SetupInitAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(SetupInitScene.self) { _ in
            let viewController = UIStoryboard.createController(SetupInitViewController.self)
            return viewController
        }
        
    }
    
}
