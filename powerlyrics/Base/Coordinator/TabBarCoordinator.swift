//
//  TabBarCoordinator.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Swinject
import UIKit

class TabBarCoordinator: Coordinator {
    
    let window: UIWindow

    init(window: UIWindow, resolver: Resolver) {
        self.window = window
        super.init(resolver: resolver)
    }
    
    // MARK: - Coordinator
    
    override func start() {
        let tabBarController = UITabBarController()
        
        childCoordinators = [
            /* Home */
            resolver.resolve(
                HomeCoordinator.self,
                argument: Router()
            ),
            /* Search */
            resolver.resolve(
                SearchCoordinator.self,
                argument: Router()
            ),
            /* GenreMap */
            resolver.resolve(
                GenreMapCoordinator.self,
                argument: Router()
            ),
            /* Profile */
            resolver.resolve(
                ProfileCoordinator.self,
                argument: Router()
            )
        ].compactMap { $0 }
        
        childCoordinators.forEach { $0.start() }
        
        tabBarController.setViewControllers(childCoordinators.map { $0.rootViewController }, animated: false)

        window.rootViewController = tabBarController
    }
    
}
