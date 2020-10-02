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
        tabBarController.viewControllers = []

        let homeTab = createNavigationController(withTitle: Strings.TabBar.home)
        let homeCoordinator = resolver.resolve(HomeCoordinator.self, argument: homeTab)!
        
        childCoordinators = [homeCoordinator]
        homeCoordinator.start()

        let rootViewControllers = [homeTab]
        tabBarController.setViewControllers(rootViewControllers, animated: false)

        window.rootViewController = tabBarController
    }

    // MARK: - Creating tabs
    
    func createNavigationController(withTitle title: String) -> Router {
        let navController = Router()

        navController.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: "music.note.house"),
            selectedImage: nil
        )

        return navController
    }
    
}
