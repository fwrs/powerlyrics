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
import UIKit

// MARK: - Constants

fileprivate extension Constants {
    
    static let pleaseWaitText = "Please wait"
    static let googleServicePlist = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
    
}

// MARK: - SceneDelegate

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Instance methods
    
    var window: UIWindow?
    
    var resolver: Resolver = Config.getResolver()
    
    var loadingAlert: UIAlertController?
    
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
    
    lazy var tabBarCoordinator: TabBarCoordinator = {
        resolver.resolve(TabBarCoordinator.self)!
    }()
    
    // MARK: - Scene lifecycle
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.makeKeyAndVisible()
        window?.windowScene = windowScene
        
        // MARK: - Config
        
        UIView.appearance().tintColor = .tintColor
        
        Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        
        let filePath = Constants.googleServicePlist!
        let options = FirebaseOptions(contentsOfFile: filePath)
        FirebaseApp.configure(options: options!)
        
        // MARK: - Start
        
        tabBarCoordinator.start()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        spotifyProvider.logout(reset: false)
        spotifyProvider.handle(url: url) { [self] in
            let loadingAlert = UIAlertController(title: nil, message: nil, preferredStyle: .alert).with {
                $0.addLoadingUI(title: Constants.pleaseWaitText)
            }
            alertTopMostViewController(controller: loadingAlert)
            self.loadingAlert = loadingAlert
            loadUserData { [self] in
                window?.rootViewController?.presentedViewController?.dismiss(animated: true, completion: {
                    window?.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
                })
                if let homeViewController = ((window?.rootViewController as? UITabBarController)?.viewControllers?.first as? Router)?.viewControllers.first as? HomeViewController {
                    homeViewController.viewModel.loadData()
                    homeViewController.viewModel.checkSpotifyAccount()
                }
                if let profileViewController = ((window?.rootViewController as? UITabBarController)?.viewControllers?.last as? Router)?.viewControllers.first as? ProfileViewController {
                    profileViewController.viewModel.loadData()
                }
            } failure: { [self] underage in
                if let alert = self.loadingAlert {
                    alert.dismiss(animated: true, completion: nil)
                }
                spotifyProvider.logout(reset: true)
                if underage {
                    alertTopMostViewController(controller: Constants.unsuitableForMinorsAlert.with {
                        $0.addAction(UIAlertAction(title: Constants.ok, style: .default, handler: nil))
                    })
                } else {
                    alertTopMostViewController(controller: Constants.failedToSignInAlert.with {
                        $0.addAction(UIAlertAction(title: Constants.ok, style: .default, handler: nil))
                    })
                }
            }
        }
    }
    
    // MARK: - Helper methods
    
    func alertTopMostViewController(controller: UIAlertController) {
        window?.topViewController?.present(controller, animated: true)
    }
    
    func loadUserData(success: @escaping DefaultAction, failure: @escaping DefaultBoolAction) {
        spotifyProvider.reactive
            .request(.userInfo)
            .map(SpotifyUserInfoResponse.self)
            .start { [self] event in
                switch event {
                case .value(let response):
                    if response.explicitContent.filterEnabled == true && response.explicitContent.filterLocked == true {
                        failure(true)
                        return
                    }
                    
                    realmService.saveUserData(spotifyUserInfo: response)
                    keychainService.setEncodable(true, for: .spotifyAuthorizedWithAccount)
                    success()
                case .failed:
                    failure(false)
                default:
                    break
                }
            }
    }
    
}
