//
//  LyricsCoordinator.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/3/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import SafariServices
import Swinject

// MARK: - LyricsCoordinator

class LyricsCoordinator: Coordinator {
    
    // MARK: - Instance properties
    
    let source: UIViewController
    
    let song: SharedSong
    
    let placeholder: UIImage?
    
    var router: Router?
    
    weak var presenter: PresenterCoordinator?
    
    // MARK: - Init

    init(
        source: UIViewController,
        resolver: Resolver,
        presenter: PresenterCoordinator,
        song: SharedSong,
        placeholder: UIImage?
    ) {
        self.source = source
        self.presenter = presenter
        self.song = song
        self.placeholder = placeholder
        super.init(resolver: resolver)
    }
    
    // MARK: - Coordinator
    
    override func start() {
        let scene = resolver.resolve(LyricsScene.self, arguments: song, placeholder)!
        let router = Router(rootViewController: scene)
        
        router.modalPresentationStyle = .custom
        router.transitioningDelegate = self
        scene.flowSafari = { [weak self] url in
            self?.showSafari(url: url)
        }
        scene.flowStory = { [weak self] story in
            self?.showStory(story: story)
        }
        scene.flowDismiss = { [weak self] in
            scene.dismiss(animated: true, completion: {
                self?.presenter?.clearChildren(Self.self)
            })
        }
        source.present(router, animated: true)
        self.router = router
    }
    
    // MARK: - Scenes
    
    func showSafari(url: URL) {
        guard let router = self.router else { return }
        
        let safariViewController = SFSafariViewController(url: url, configuration: SFSafariViewController.Configuration())
        safariViewController.preferredControlTintColor = .tintColor
        router.present(safariViewController, animated: true)
    }
    
    func showStory(story: String) {
        guard let router = self.router else { return }
        
        let scene = resolver.resolve(LyricsStoryScene.self, argument: story)!
        
        let blurView = UIVisualEffectView(effect: nil)
        
        UIView.animate(withDuration: Constants.defaultAnimationDuration, options: .curveEaseOut) {
            blurView.effect = UIBlurEffect(style: Constants.globalBlurStyle)
        }
        
        router.view.addSubview(blurView)
        blurView.isUserInteractionEnabled = false
        blurView.frame = UIScreen.main.bounds
        router.view.bringSubviewToFront(blurView)
        
        scene.flowDismiss = {
            UIView.animate(withDuration: Constants.defaultAnimationDuration, options: .curveEaseOut) {
                blurView.effect = nil
            } completion: { _ in
                blurView.removeFromSuperview()
            }
        }
        
        router.presentPanModal(scene)
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
