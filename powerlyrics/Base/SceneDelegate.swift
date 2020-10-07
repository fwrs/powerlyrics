//
//  SceneDelegate.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import IQKeyboardManager
import Swinject
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private var resolver: Resolver = Config.getResolver()
    
    lazy var tabBarCoordinator: TabBarCoordinator = {
        resolver.resolve(TabBarCoordinator.self)!
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.makeKeyAndVisible()
        window?.windowScene = windowScene
        
        // MARK: - Config
        
        UIView.appearance().tintColor = .tintColor
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        
        // MARK: - Start

        tabBarCoordinator.start()
    }

}
