//
//  SceneDelegate.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Firebase
import IQKeyboardManager
import RealmSwift
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
        
        Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        
        let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!
        let options = FirebaseOptions(contentsOfFile: filePath)
        FirebaseApp.configure(options: options!)
        
        // MARK: - Start
        
        tabBarCoordinator.start()
    }
    
    var loadingAlert: UIAlertController?
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        spotifyProvider.logout(reset: false)
        spotifyProvider.handle(url: url) { [self] in
            let loadingAlert = UIAlertController(title: nil, message: nil, preferredStyle: .alert).with {
                $0.addLoadingUI()
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
                    profileViewController.viewModel.updateData()
                }
            } failure: { [self] underage in
                if let alert = self.loadingAlert {
                    alert.dismiss(animated: true, completion: nil)
                }
                spotifyProvider.logout(reset: true)
                if underage {
                    alertTopMostViewController(controller: UIAlertController(title: "Unsuitable for minors", message: "You have to be over 18 years old in order to use this app.", preferredStyle: .alert).with {
                        $0.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    })
                } else {
                    alertTopMostViewController(controller: UIAlertController(title: "Failed to sign in", message: "Please try again.", preferredStyle: .alert).with {
                        $0.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    })
                }
            }
        }
    }
    
    func alertTopMostViewController(controller: UIAlertController) {
        window?.topViewController?.present(controller, animated: true)
    }
    
    func loadUserData(success: @escaping DefaultAction, failure: @escaping DefaultBoolAction) {
        spotifyProvider.reactive
            .request(.userInfo)
            .map(SpotifyUserInfoResponse.self)
            .start { event in
                switch event {
                case .value(let response):
                    if response.explicitContent.filterEnabled == true && response.explicitContent.filterLocked == true {
                        failure(true)
                        return
                    }
                    
                    Realm.saveUserData(spotifyUserInfo: response)
                    Config.getResolver().resolve(KeychainStorageProtocol.self)!.setEncodable(true, for: .spotifyAuthorizedWithAccount)
                    success()
                case .failed:
                    failure(false)
                default:
                    break
                }
            }
    }
    
}
