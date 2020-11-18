//
//  LyricsCoordinator.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/3/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import SafariServices
import Swinject
import UIKit

// MARK: - LyricsCoordinator

class LyricsCoordinator: Coordinator {
    
    // MARK: - Instance properties
    
    let router: Router
    
    let base: UIViewController
    
    let dismissCompletion: DefaultAction
    
    let song: SharedSong
    
    let placeholder: UIImage?
    
    // MARK: - Init

    init(
        router: Router,
        resolver: Resolver,
        base: UIViewController,
        dismissCompletion: @escaping DefaultAction,
        song: SharedSong,
        placeholder: UIImage?
    ) {
        self.router = router
        self.base = base
        self.dismissCompletion = dismissCompletion
        self.song = song
        self.placeholder = placeholder
        super.init(resolver: resolver)
    }
    
    // MARK: - Coordinator
    
    override func start() {
        let scene = resolver.resolve(LyricsScene.self, arguments: song, placeholder)!
        scene.flowDismiss = { [self] in
            base.dismiss(animated: true, completion: {
                dismissCompletion()
            })
        }
        scene.flowSafari = { [weak self] url in
            self?.showSafari(url: url)
        }
        router.push(scene, animated: false)
        router.modalPresentationStyle = .custom
        router.transitioningDelegate = self
        base.present(router, animated: true)
    }
    
    override var rootViewController: UIViewController {
        router
    }
    
    // MARK: - Scenes
    
    func showSafari(url: URL) {
        let safariViewController = SFSafariViewController(url: url, configuration: SFSafariViewController.Configuration())
        safariViewController.preferredControlTintColor = .tintColor
        router.present(safariViewController, animated: true)
    }

}

// MARK: - UIViewControllerTransitioningDelegate

extension LyricsCoordinator: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        TranslationAnimation(type: .dismiss, duration: 0.5, interactionController: (dismissed as? TranslationAnimationView)?.translationInteractor)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        TranslationAnimation(type: .present, duration: 0.5)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning)
      -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animator as? TranslationAnimation,
              let interactionController = animator.interactionController,
              interactionController.interactionInProgress
        else {
            return nil
        }
        
        return interactionController
    }
    
}
