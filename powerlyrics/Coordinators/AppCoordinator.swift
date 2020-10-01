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
}

// MARK: - CoordinatorProtocol
extension AppCoordinator {
    func start() {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = []

        let sampleTab = createNavigationController(withTitle: "Sample")

        let sampleCoordinator = resolver.resolve(SampleCoordinator.self, argument: sampleTab)!
        coordinators.append(sampleCoordinator)
        sampleCoordinator.start()

        let rootViewControllers = [sampleTab]
        tabBarController.setViewControllers(rootViewControllers, animated: false)

        window.rootViewController = tabBarController
    }
}

// MARK: - Creating tabs
extension AppCoordinator {
    func createNavigationController(withTitle title: String) -> Router {
        let navController = Router()

        navController.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: "square.and.pencil"),
            selectedImage: nil
        )

        return navController
    }
}
