//
//  TabBarCoordinator.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Swinject

// MARK: - Constants

fileprivate extension Constants {
    
    static let numberOfTabs = Int.four
    
}

// MARK: - TabBarCoordinator

class TabBarCoordinator: Coordinator {
    
    let window: UIWindow

    init(window: UIWindow, resolver: Resolver) {
        self.window = window
        super.init(resolver: resolver)
    }
    
    // MARK: - Coordinator
    
    override func start() {
        let tabBarController = UITabBarController()
        
        let routers = [Router(), Router(), Router(), Router()]
        
        childCoordinators = [
            /* Home */
            resolver.resolve(
                HomeCoordinator.self,
                argument: routers[.zero]
            ),
            /* Search */
            resolver.resolve(
                SearchCoordinator.self,
                argument: routers[.one]
            ),
            /* GenreMap */
            resolver.resolve(
                GenreMapCoordinator.self,
                argument: routers[.two]
            ),
            /* Profile */
            resolver.resolve(
                ProfileCoordinator.self,
                argument: routers[.three]
            )
        ].compactMap { $0 }
        
        childCoordinators.forEach { $0.start() }
        
        tabBarController.setViewControllers(routers, animated: false)
        
        DispatchQueue.once {
            window.rootViewController = tabBarController
        }

        DispatchQueue.allButOnce {
            UIView.fadeUpdate(window) { [weak self] in
                self?.window.rootViewController = tabBarController
            }
        }
    }
    
}
