//
//  TranslationAnimation.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//

import UIKit

protocol TranslationAnimationView {
    var translationViews: [UIView] { get }
    var isInteractiveDismissal: Bool { get }
    var interactionController: TranslationAnimationInteractor? { get }
}

class TranslationAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum TransitionType {
        case present
        case dismiss
    }

    let type: TransitionType
    
    let duration: TimeInterval
    
    let interactionController: TranslationAnimationInteractor?

    init(type: TransitionType, duration: TimeInterval, interactionController: TranslationAnimationInteractor? = nil) {
        self.type = type
        self.duration = duration
        self.interactionController = interactionController
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        type == .dismiss ? duration / 1.2 : duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from) as! TranslationAnimationView  & UIViewController
        let toVC   = transitionContext.viewController(forKey: .to)   as! TranslationAnimationView  & UIViewController

        let container = transitionContext.containerView

        toVC.view.frame = fromVC.view.frame
        if type == .present {
            container.addSubview(toVC.view)
        } else {
            container.insertSubview(toVC.view, belowSubview: fromVC.view)
        }
        toVC.view.layoutIfNeeded()

        let fromSnapshots = fromVC.translationViews.map { subview -> UIView in
            let snapshot = subview.snapshotView(afterScreenUpdates: false)!
            snapshot.frame = container.convert(subview.frame, from: subview.superview)
            return snapshot
        }

        let toSnapshots = toVC.translationViews.map { subview -> UIView in
            let snapshot = subview.snapshotView(afterScreenUpdates: true)!
            snapshot.frame = container.convert(subview.frame, from: subview.superview)
            return snapshot
        }

        let frames = zip(fromSnapshots, toSnapshots).map { ($0.frame, $1.frame) }

        zip(toSnapshots, frames).forEach { snapshot, frame in
            snapshot.frame = frame.0
            snapshot.alpha = 0
            container.addSubview(snapshot)
        }
        
        fromSnapshots.forEach { container.addSubview($0) }
        fromVC.translationViews.forEach { $0.alpha = 0 }
        toVC.translationViews.forEach { $0.alpha = 0 }
        
        if type == .present {
            toVC.view.transform = .init(translationX: toVC.view.frame.width, y: 0)
        } else {
            toVC.view.alpha = 0.5
            toVC.view.transform = .init(translationX: -(fromVC.view.bounds.width / 3), y: 0)
        }
        
        let animationsClosure = {
            zip(toSnapshots, frames).forEach { snapshot, frame in
                snapshot.frame = frame.1
                snapshot.alpha = 1
            }

            zip(fromSnapshots, frames).forEach { snapshot, frame in
                snapshot.frame = frame.1
                snapshot.alpha = 0
            }

            if self.type == .present {
                toVC.view.transform = .identity
                fromVC.view.alpha = 0.5
                fromVC.view.transform = .init(translationX: -(fromVC.view.bounds.width / 3), y: 0)
            } else {
                fromVC.view.transform = .init(translationX: fromVC.view.frame.width, y: 0)
                toVC.view.alpha = 1
                toVC.view.transform = .identity
            }
        }
        
        let completionClosure = { (_: Bool) in
            fromSnapshots.forEach { $0.removeFromSuperview() }
            toSnapshots.forEach { $0.removeFromSuperview() }
            fromVC.translationViews.forEach { $0.alpha = 1 }
            toVC.translationViews.forEach { $0.alpha = 1 }
            
            fromVC.view.alpha = 1
            fromVC.view.transform = .identity
            toVC.view.alpha = 1
            toVC.view.transform = .identity

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        if transitionContext.isInteractive {
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveLinear, animations: animationsClosure, completion: completionClosure)
        } else {
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0, animations: animationsClosure, completion: completionClosure)
        }
    }
    
}

class PresentationController: UIPresentationController {
    
    override var shouldRemovePresentersView: Bool { true }
    
}

extension UITabBarController: TranslationAnimationView {
    
    var translationViews: [UIView] {
        (selectedViewController as! TranslationAnimationView).translationViews
    }
    
    var isInteractiveDismissal: Bool {
        (selectedViewController as! TranslationAnimationView).isInteractiveDismissal
    }
    
    var interactionController: TranslationAnimationInteractor? {
        (selectedViewController as! TranslationAnimationView).interactionController
    }
    
}

extension Router: TranslationAnimationView {
    
    var translationViews: [UIView] {
        (topViewController as! TranslationAnimationView).translationViews
    }
    
    var isInteractiveDismissal: Bool {
        (topViewController as! TranslationAnimationView).isInteractiveDismissal
    }
    
    var interactionController: TranslationAnimationInteractor? {
        (topViewController as! TranslationAnimationView).interactionController
    }
    
}

class TranslationAnimationInteractor: UIPercentDrivenInteractiveTransition {
    
    var interactionInProgress = false

    private var shouldCompleteTransition = false
    private weak var viewController: UIViewController!

    init(viewController: UIViewController) {
        super.init()
        self.viewController = viewController
        prepareGestureRecognizer(in: viewController.view)
    }
    
    private func prepareGestureRecognizer(in view: UIView) {
        let gesture = UIScreenEdgePanGestureRecognizer(target: self,
                                                       action: #selector(handleGesture(_:)))
        gesture.edges = .left
        view.addGestureRecognizer(gesture)
    }

    @objc func handleGesture(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        // 1
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
        var progress = (translation.x / 350)
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        
        switch gestureRecognizer.state {
        
        // 2
        case .began:
            interactionInProgress = true
            viewController.dismiss(animated: true, completion: nil)
            
        // 3
        case .changed:
            shouldCompleteTransition = progress > 0.5
            update(progress)
            
        // 4
        case .cancelled:
            interactionInProgress = false
            cancel()
            
        // 5
        case .ended:
            interactionInProgress = false
            if shouldCompleteTransition {
                finish()
            } else {
                cancel()
            }
        default:
            break
        }
    }

}
