//
//  AppCoordinatorAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Swinject
import UIKit

class CoordinatorsAssembly: Assembly {
    
    override func assemble(container: Container) {
        
        container.register(AppCoordinator.self) { resolver in
            AppCoordinator(window: resolver.resolve(UIWindow.self)!, resolver: resolver)
        }
        
        container.register(HomeCoordinator.self) { (resolver, router: Router) in
            HomeCoordinator(router: router, resolver: resolver)
        }
        
    }
    
}
