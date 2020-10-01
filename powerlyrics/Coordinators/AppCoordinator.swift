//
//  AppCoordinator.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Swinject
import UIKit

class AppCoordinator: CoordinatorProtocol {
    
    let window: UIWindow
    
    let resolver: Resolver

    var coordinators: [CoordinatorProtocol] = []

    init(window: UIWindow, resolver: Resolver) {
        self.window = window
        self.resolver = resolver
    }
    
    // MARK: - CoordinatorProtocol
    
    func start() {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = []

        let homeTab = createNavigationController(withTitle: Strings.TabBar.home)

        let homeCoordinator = resolver.resolve(HomeCoordinator.self, argument: homeTab)!
        coordinators.append(homeCoordinator)
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
