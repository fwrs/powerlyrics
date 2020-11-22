//
//  SceneDelegate.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Firebase
import IQKeyboardManager
import RealmSwift
import Swinject
import Then

// MARK: - Constants

fileprivate extension Constants {
    
    static let googleServicePlist = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
    
}

// MARK: - SceneDelegate

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Instance properties
    
    var window: UIWindow?
    
    var resolver: Resolver = Config.getResolver()
    
    var tabBarCoordinator: TabBarCoordinator!
    
    // MARK: - DI
    
    lazy var spotifyProvider: SpotifyProvider = {
        resolver.resolve(SpotifyProvider.self)!
    }()
    
    lazy var keychainService: KeychainServiceProtocol = {
        resolver.resolve(KeychainServiceProtocol.self)!
    }()
    
    lazy var realmService: RealmServiceProtocol = {
        resolver.resolve(RealmServiceProtocol.self)!
    }()
    
    // MARK: - Scene lifecycle
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.makeKeyAndVisible()

        // MARK: - Config
        
        UIView.appearance().tintColor = .tintColor
        
        Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        
        let filePath = Constants.googleServicePlist!
        
        if FirebaseApp.app() == nil {
            let options = FirebaseOptions(contentsOfFile: filePath)
            FirebaseApp.configure(options: options!)
        }
        
        _ = NotificationCenter.default.addObserver(
            forName: .appDidLogout,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.start()
        }
        
        if realmService.userData == nil && spotifyProvider.loggedIn {
            spotifyProvider.logout()
        }
        
        start()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        NotificationCenter.default.post(name: .appDidOpenURL, object: nil, userInfo: [
            NotificationKey.url: url
        ])
    }
    
    // MARK: - Scene start
    
    func start() {
        tabBarCoordinator = resolver.resolve(TabBarCoordinator.self)!
        tabBarCoordinator.start()
    }

}
