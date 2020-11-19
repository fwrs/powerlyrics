//
//  SetupCoordinator.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Swinject

// MARK: - SetupMode

enum SetupMode {
    case initial
    case manual
}

typealias DefaultSetupModeAction = (SetupMode) -> Void

// MARK: - SetupCoordinator

class SetupCoordinator: Coordinator {
    
    // MARK: - DI
    
    let spotifyProvider: SpotifyProvider
    
    // MARK: - Instance properties
    
    let source: UIViewController
    
    let router: Router
    
    let mode: SetupMode
    
    var interactionController: UIPercentDrivenInteractiveTransition?
    
    weak var presenter: PresenterCoordinator?
    
    // MARK: - Init

    init(
        source: UIViewController,
        resolver: Resolver,
        presenter: PresenterCoordinator,
        spotifyProvider: SpotifyProvider,
        mode: SetupMode
    ) {
        self.source = source
        self.mode = mode
        self.router = Router()
        self.presenter = presenter
        self.spotifyProvider = spotifyProvider
        
        super.init(resolver: resolver)
        
        router.delegate = self
        
        if mode == .initial {
            router.isModalInPresentation = true
        }
    }
    
    // MARK: - Coordinator
    
    override func start() {
        if mode == .initial {
            showInitSetup()
        } else if mode == .manual {
            showManualSetup()
        }
    }

    // MARK: - Scenes
    
    func showInitSetup() {
        let scene = resolver.resolve(SetupInitScene.self)!
        scene.flowDismiss = { [weak self] in
            self?.source.dismiss(animated: true, completion: {
                self?.presenter?.clearChildren(Self.self)
            })
        }
        scene.flowOfflineSetup = { [weak self] in
            self?.showOfflineSetup()
        }
        scene.flowSpotifyLogin = { [weak self] in
            self?.spotifyProvider.login(from: scene)
        }
        router.push(scene, animated: false)
        source.present(router, animated: true)
    }
    
    func showManualSetup() {
        let scene = resolver.resolve(SetupManualScene.self)!
        scene.flowDismiss = { [weak self] in
            self?.source.dismiss(animated: true, completion: {
                self?.presenter?.clearChildren(Self.self)
            })
        }
        scene.flowSpotifyLogin = { [weak self] in
            self?.spotifyProvider.login(from: scene)
        }
        router.push(scene, animated: false)
        source.present(router, animated: true)
    }
    
    func showOfflineSetup() {
        let scene = resolver.resolve(SetupOfflineScene.self)!
        scene.flowDismiss = { [weak self] in
            self?.source.dismiss(animated: true, completion: {
                self?.presenter?.clearChildren(Self.self)
            })
        }
        router.push(scene)
    }

}

// MARK: - UINavigationControllerDelegate

extension SetupCoordinator: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            return TranslationAnimation(type: .present, duration: 0.5, inNavigationController: true)
        case .pop:
            return TranslationAnimation(type: .dismiss, duration: 0.5, interactionController: (fromVC as? TranslationAnimationView)?.translationInteractor, inNavigationController: true)
        default:
            return nil
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animationController as? TranslationAnimation,
              let interactionController = animator.interactionController,
              interactionController.interactionInProgress
        else {
            return nil
        }
        
        return interactionController
    }
    
}
