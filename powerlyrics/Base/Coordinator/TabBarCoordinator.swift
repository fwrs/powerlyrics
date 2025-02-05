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
    
    static let numberOfTabs = 4
    
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
        configureUI(for: tabBarController)
        
        let routers = Array(repeating: (), count: Constants.numberOfTabs).map { Router() }
        
        childCoordinators = [
            /* Home */
            resolver.resolve(
                HomeCoordinator.self,
                argument: routers[0]
            ),
            /* Search */
            resolver.resolve(
                SearchCoordinator.self,
                argument: routers[1]
            ),
            /* GenreMap */
            resolver.resolve(
                GenreMapCoordinator.self,
                argument: routers[2]
            ),
            /* Profile */
            resolver.resolve(
                ProfileCoordinator.self,
                argument: routers[3]
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
    
    func configureUI(for tabBarController: UITabBarController) {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBarController.tabBar.standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            tabBarController.tabBar.scrollEdgeAppearance = appearance
        }
    }
    
}
