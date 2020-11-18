//
//  SetupManualAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Swinject
import UIKit

// MARK: - SetupManualScene

protocol SetupManualScene: ViewController {
    
    var flowDismiss: DefaultAction? { get set }
    var flowSpotifyLogin: DefaultAction? { get set }
    
}

// MARK: - SetupManualAssembly

class SetupManualAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(SetupManualScene.self) { _ in
            let viewController = UIStoryboard.createController(SetupManualViewController.self)
            return viewController
        }
        
    }
    
}
