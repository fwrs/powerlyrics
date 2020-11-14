//
//  TranslationAnimation.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//

import UIKit

protocol TranslationAnimationView {
    var translationViews: [UIView] { get }
    var translationInteractor: TranslationAnimationInteractor? { get }
    var completelyMoveAway: Bool { get }
    var isSourcePanModal: Bool { get }
}

extension TranslationAnimationView {
    var completelyMoveAway: Bool { false }
    var isSourcePanModal: Bool { false }
}

class TranslationAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum TransitionType {
        case present
        case dismiss
    }

    let type: TransitionType
    
    let duration: TimeInterval
    
    let interactionController: TranslationAnimationInteractor?
    
    let inNavigationController: Bool

    init(type: TransitionType, duration: TimeInterval, interactionController: TranslationAnimationInteractor? = nil, inNavigationController: Bool = false) {
        self.type = type
        self.duration = duration
        self.interactionController = interactionController
        self.inNavigationController = inNavigationController
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        type == .dismiss ? duration / 1.2 : duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from) as! TranslationAnimationView  & UIViewController
        let toVC   = transitionContext.viewController(forKey: .to)   as! TranslationAnimationView  & UIViewController
        
        let fromVCCorrectedView = fromVC.isSourcePanModal ? fromVC.view.superview! : fromVC.view!
        let toVCCorrectedView = toVC.isSourcePanModal ? toVC.view.superview! : toVC.view!

        let container = transitionContext.containerView

        if !toVC.isSourcePanModal && fromVC.isSourcePanModal {
            toVCCorrectedView.frame = UIScreen.main.bounds
        } else if !toVC.isSourcePanModal {
            toVCCorrectedView.frame = fromVCCorrectedView.frame
        }
        if type == .present {
            container.addSubview(toVCCorrectedView)
        } else {
            if !toVC.isSourcePanModal {
                container.insertSubview(toVCCorrectedView, belowSubview: fromVCCorrectedView)
            }
        }
        
        toVCCorrectedView.layoutIfNeeded()
        
        let fromSnapshots = (toVC.translationViews.isEmpty ? [] : fromVC.translationViews).map { subview -> UIView in
            let snapshot = subview.snapshotView(afterScreenUpdates: !inNavigationController)!
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
        if fromVC.translationViews.nonEmpty && toVC.translationViews.nonEmpty {
            fromVC.translationViews.forEach { $0.alpha = 0 }
            toVC.translationViews.forEach { $0.alpha = 0 }
        }
        
        if type == .present {
            toVCCorrectedView.transform = .init(translationX: toVCCorrectedView.frame.width, y: 0)
            if fromVC.completelyMoveAway {
                toVCCorrectedView.alpha = 0
            }
        } else {
            if toVC.completelyMoveAway {
                toVCCorrectedView.alpha = 0
            }
            toVCCorrectedView.alpha = toVC.completelyMoveAway ? 0 : 0.5
            toVCCorrectedView.transform = .init(translationX: -(toVCCorrectedView.bounds.width / (toVC.completelyMoveAway ? 1 : 3.35)), y: 0)
        }
        
        let animationsClosure = {
            zip(toSnapshots, frames).forEach { snapshot, frame in
                snapshot.frame = frame.1
                snapshot.alpha = 1
            }

            zip(fromSnapshots, frames).forEach { [self] snapshot, frame in
                snapshot.frame = frame.1
                snapshot.alpha = inNavigationController ? 1 : 0
            }

            if self.type == .present {
                toVCCorrectedView.transform = .identity
                fromVCCorrectedView.alpha = fromVC.completelyMoveAway ? 0 : 0.5
                fromVCCorrectedView.transform = .init(translationX: -(fromVCCorrectedView.bounds.width / (fromVC.completelyMoveAway ? 1 : 3)), y: 0)
                if fromVC.completelyMoveAway {
                    toVCCorrectedView.alpha = 1
                }
            } else {
                fromVCCorrectedView.transform = .init(translationX: fromVCCorrectedView.frame.width, y: 0)
                toVCCorrectedView.alpha = 1
                if toVC.completelyMoveAway {
                    fromVCCorrectedView.alpha = 0
                    toVCCorrectedView.alpha = 1
                }
                toVCCorrectedView.transform = .identity
            }
        }
        
        let completionClosure = { (_: Bool) in
            fromSnapshots.forEach { $0.removeFromSuperview() }
            toSnapshots.forEach { $0.removeFromSuperview() }
            fromVC.translationViews.forEach { $0.alpha = 1 }
            toVC.translationViews.forEach { $0.alpha = 1 }
            
            fromVCCorrectedView.alpha = 1
            fromVCCorrectedView.transform = .identity
            
            toVCCorrectedView.alpha = 1
            toVCCorrectedView.transform = .identity

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        if transitionContext.isInteractive {
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveLinear, animations: animationsClosure, completion: completionClosure)
        } else {
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: type == .present ? .curveEaseOut : .curveEaseIn, animations: animationsClosure, completion: completionClosure)
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
    
    var translationInteractor: TranslationAnimationInteractor? {
        (selectedViewController as! TranslationAnimationView).translationInteractor
    }
    
    var isSourcePanModal: Bool {
        (selectedViewController as! TranslationAnimationView).isSourcePanModal
    }
    
}

extension Router: TranslationAnimationView {
    
    var translationViews: [UIView] {
        (topViewController as! TranslationAnimationView).translationViews
    }
    
    var translationInteractor: TranslationAnimationInteractor? {
        (topViewController as! TranslationAnimationView).translationInteractor
    }
    
    var isSourcePanModal: Bool {
        (topViewController as! TranslationAnimationView).isSourcePanModal
    }
    
}

class TranslationAnimationInteractor: UIPercentDrivenInteractiveTransition {
    
    var interactionInProgress = false

    private var shouldCompleteTransition = false
    private weak var viewController: UIViewController!
    private var pop: Bool
    
    var gesture: UIScreenEdgePanGestureRecognizer?

    init(viewController: UIViewController, pop: Bool = false) {
        self.pop = pop
        super.init()
        self.viewController = viewController
        prepareGestureRecognizer(in: viewController.view)
    }
    
    private func prepareGestureRecognizer(in view: UIView) {
        let newGesture = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(handleGesture(_:))
        )
        newGesture.edges = .left
        view.addGestureRecognizer(newGesture)
        gesture = newGesture
    }

    @objc func handleGesture(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
        var progress = (translation.x / 395)
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        
        switch gestureRecognizer.state {
        
        case .began:
            interactionInProgress = true
            if pop {
                viewController.navigationController?.popViewController(animated: true)
            } else {
                viewController.dismiss(animated: true, completion: nil)
            }
            
        case .changed:
            shouldCompleteTransition = progress > 0.3
            update(progress)
            
        case .cancelled:
            interactionInProgress = false
            cancel()
            
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
