//
//  CoordinatorsAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Swinject
import UIKit

class CoordinatorsAssembly: Assembly {
    
    override func assemble(container: Container) {
        
        // MARK: - Tab Bar
        
        container.register(TabBarCoordinator.self) { resolver in
            TabBarCoordinator(window: resolver.resolve(UIWindow.self)!, resolver: resolver)
        }
        
        // MARK: - Tab Bar items
        
        container.register(HomeCoordinator.self) { (resolver, router: Router) in
            HomeCoordinator(router: router, resolver: resolver)
        }
        
        container.register(SearchCoordinator.self) { (resolver, router: Router) in
            SearchCoordinator(router: router, resolver: resolver)
        }
        
        container.register(GenreMapCoordinator.self) { (resolver, router: Router) in
            GenreMapCoordinator(router: router, resolver: resolver)
        }
        
        container.register(ProfileCoordinator.self) { (resolver, router: Router) in
            ProfileCoordinator(router: router, resolver: resolver)
        }
        
    }
    
}
