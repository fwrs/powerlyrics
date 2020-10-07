//
//  SetupCoordinator.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//

import Swinject
import UIKit

typealias DefaultSetupModeAction = (SetupMode) -> Void

enum SetupMode {
    case initial
    case manual
}

class SetupCoordinator: Coordinator {
    
    let mode: SetupMode
    
    let router: Router
    
    let base: UIViewController
    
    let dismissCompletion: DefaultAction
    
    var interactionController: UIPercentDrivenInteractiveTransition?

    init(mode: SetupMode, router: Router, resolver: Resolver, base: UIViewController, dismissCompletion: @escaping DefaultAction) {
        self.mode = mode
        self.router = router
        self.base = base
        self.dismissCompletion = dismissCompletion
        super.init(resolver: resolver)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        router.delegate = self
        if mode == .initial {
            router.isModalInPresentation = true
        }
    }
    
    func showInitSetup() {
        let scene = resolver.resolve(SetupInitScene.self)!
        scene.flowDismiss = { [self] in
            base.dismiss(animated: true, completion: {
                dismissCompletion()
            })
        }
        scene.flowOfflineSetup = { [self] in
            showOfflineSetup()
        }
        router.push(scene, animated: false)
        base.present(router, animated: true)
    }
    
    func showManualSetup() {
        let scene = resolver.resolve(SetupManualScene.self)!
        scene.flowDismiss = { [self] in
            base.dismiss(animated: true, completion: {
                dismissCompletion()
            })
        }
        router.push(scene, animated: false)
        base.present(router, animated: true)
    }
    
    func showOfflineSetup() {
        let scene = resolver.resolve(SetupOfflineScene.self)!
        scene.flowDismiss = { [self] in
            base.dismiss(animated: true, completion: {
                dismissCompletion()
            })
        }
        router.push(scene, animated: true)
    }
    
    override func start() {
        if mode == .initial {
            showInitSetup()
        } else if mode == .manual {
            showManualSetup()
        }
    }
    
    override var rootViewController: UIViewController {
        router
    }

}

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
