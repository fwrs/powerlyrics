//
//  LyricsCoordinator.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/3/20.
//

import Swinject
import UIKit

class LyricsCoordinator: Coordinator {
    
    let router: Router
    
    let base: UIViewController
    
    let dismissCompletion: DefaultAction
    
    let song: Song

    init(router: Router, resolver: Resolver, base: UIViewController, dismissCompletion: @escaping DefaultAction, song: Song) {
        self.router = router
        self.base = base
        self.dismissCompletion = dismissCompletion
        self.song = song
        super.init(resolver: resolver)
    }
    
    override func start() {
        let scene = resolver.resolve(LyricsScene.self, argument: song)!
        scene.flowDismiss = { [self] in
            base.dismiss(animated: true, completion: {
                dismissCompletion()
            })
        }
        router.push(scene, animated: false)
        router.modalPresentationStyle = .custom
        router.transitioningDelegate = self
        base.present(router, animated: true)
    }
    
    override var rootViewController: UIViewController {
        router
    }

}

extension LyricsCoordinator: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        TranslationAnimation(type: .dismiss, duration: 0.4, interactionController: (dismissed as? TranslationAnimationView)?.interactionController)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        TranslationAnimation(type: .present, duration: 0.4)
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
