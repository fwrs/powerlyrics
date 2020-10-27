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
    
    lazy var spotifyProvider: SpotifyProvider = {
        resolver.resolve(SpotifyProvider.self)!
    }()
    
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
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        spotifyProvider.handle(url: url)
        delay(0.5) { [self] in
            window?.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
            window?.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
}
