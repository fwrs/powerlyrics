//
//  GenreMapViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//

import CoreMotion
import Haptica
import ReactiveKit
import Then
import UIKit

class GenreMapViewController: ViewController, GenreMapScene {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var genreMapBackgroundView: GenreMapBackgroundView!
    
    @IBOutlet private weak var genreMapView: GenreMapView!
    
    @IBOutlet private var genreMapButtons: [UIButton]!
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    @IBOutlet private weak var secondaryMapAlignmentConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var genreStatsView: UIView!
    
    @IBOutlet private weak var gravityContainerView: UIView!
    
    @IBOutlet private weak var gravityProducerView: UIView!
    
    @IBOutlet private weak var dashedView: UIView!
    
    @IBOutlet private weak var uprightWarningView: UIView!
    
    // MARK: - Instance properties
    
    var viewModel: GenreMapViewModel!
    
    var shouldAnimate: Bool = true
    
    var motionManager: CMMotionManager?
    
    var motionDisplayLink: CADisplayLink?
    
    var animator: UIDynamicAnimator?
    
    var gravity: UIGravityBehavior?
    
    var collision: UICollisionBehavior?
    
    var bounce: UIDynamicItemBehavior?
    
    var snap: UISnapBehavior?
    
    var push: UIPushBehavior?
    
    var pushAccelerometer: UIPushBehavior?
    
    var banSnap = false
    
    var motionLastX: Double = 0
    var motionLastY: Double = 0
    
    static var qx = 0.1
    static var rx = 0.1
    static var px = 0.1
    static var kx = 0.5
    
    static var qy = 0.1
    static var ry = 0.1
    static var py = 0.1
    static var ky = 0.5
    
    var hidView = false
    
    var collider = PassthroughSubject<(), Never>()
    
    // MARK: - Flows
    
    var flowLyrics: ((Shared.Song, UIImage?) -> Void)?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        genreMapView.addBehavior()
        genreMapBackgroundView.alpha = 0
        genreMapView.alpha = 0
        descriptionLabel.alpha = 0
        for i in 0..<8 {
            genreMapButtons[i].alpha = 0
        }
        genreStatsView.isHidden = true
        motionManager = CMMotionManager()
        motionManager?.deviceMotionUpdateInterval = 0.02
        motionDisplayLink = CADisplayLink(target: self, selector: #selector(motionRefresh))
        motionDisplayLink?.add(to: RunLoop.current, forMode: .default)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldAnimate {
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseOut) { [self] in
                genreMapBackgroundView.alpha = 1
            }
            UIView.animate(withDuration: 0.9, delay: 0.15, options: .curveEaseOut) { [self] in
                genreMapView.alpha = 1
            }
            delay(0.15) { [self] in
                genreMapView.animatePathChange()
            }
            for i in 0..<8 {
                UIView.animate(withDuration: 0.5 + (Double(i) / 10), delay: 0.1 + 0.05 * Double(i) + pow(0.95, Double(i))/20, options: .curveEaseOut) { [self] in
                    genreMapButtons[i].alpha = 1
                }
            }
            UIView.animate(withDuration: 0.55, delay: 0.45, options: .curveEaseIn) { [self] in
                descriptionLabel.alpha = 1
            }
            shouldAnimate = false
        }

        let flash = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        flash.duration = 1.3
        flash.fromValue = 1
        flash.toValue = 0.3
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = .infinity
        dashedView.layer.add(flash, forKey: nil)
        if motionManager?.isDeviceMotionAvailable == true {
            motionManager?.startDeviceMotionUpdates(using: .xArbitraryZVertical)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dashedView.layer.removeAllAnimations()
        if motionManager?.isDeviceMotionAvailable == true {
            motionManager?.stopDeviceMotionUpdates()
        }
    }
    
    // MARK: - Actions
    
}

extension GenreMapViewController {
    
    // MARK: - Setup

    func setupView() {
        if !UIDevice.current.hasNotch {
            secondaryMapAlignmentConstraint.isActive = true
        }
        
        gravityContainerView.layer.zPosition = 10000
        
        let text = descriptionLabel.text.safe.typographized
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2

        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attrString.length))
        
        attrString.addAttribute(.foregroundColor, value: UIColor.tintColor, range: NSString(string: text).range(of: "liked music"))
        
        descriptionLabel.attributedText = attrString
        
        let transforms: [(CGFloat, CGFloat)] = [(1, 0), (1, 1), (0, 1), (-1, 1), (1, 0), (1, 1), (0, 1), (-1, 1)]
        
        collider.throttle(for: 0.25).observeNext { [self] _ in
            if presentedViewController == nil {
                Haptic.play(".")
            }
        }.dispose(in: disposeBag)
        
        genreMapButtons.enumerated().forEach { index, button in
            button.reactive.tap.observeNext { [self] in
                var rotationWithPerspective = CATransform3DIdentity
                rotationWithPerspective.m34 = -1.0 / 500.0
                let angle = [4, 5, 6, 7].contains(index) ? -0.5 * CGFloat.pi : 0.5 * CGFloat.pi
                
                genreStatsView.layer.transform = CATransform3DIdentity
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                    genreMapBackgroundView.layer.transform =
                        CATransform3DRotate(rotationWithPerspective, angle, transforms[index].0, transforms[index].1, 0)
                }
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                    genreMapBackgroundView.alpha = 0
                }
                
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn) {
                    var rotationWithPerspective = CATransform3DIdentity
                    rotationWithPerspective.m34 = -1.0 / 1000.0
                    descriptionLabel.layer.transform = CATransform3DRotate(CATransform3DTranslate(rotationWithPerspective, 0, -80, 0), -0.5 * CGFloat.pi, 1, 0, 0)
                }
                
                UIView.animate(withDuration: 0.18) {
                    descriptionLabel.alpha = 0
                }
                
                genreStatsView.isHidden = false
                genreStatsView.alpha = 0
                
                let backButton = UIButton(type: .custom)
                backButton.setTitle("Done", for: .normal)
                backButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
                backButton.setTitleColor(.highlightTintColor, for: .highlighted)
                backButton.setTitleColor(.tintColor, for: .normal)
                backButton.imageEdgeInsets.left -= 10
                backButton.imageEdgeInsets.right += 2
                backButton.sizeToFit()
                backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
                let barButton = UIBarButtonItem(customView: backButton)
                barButton.isEnabled = true
                backButton.alpha = 0
                navigationItem.title = button.title(for: .normal)
                
                navigationItem.leftBarButtonItem = barButton
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                    backButton.alpha = 1
                } completion: { _ in
                    button.setNeedsLayout()
                    button.layoutIfNeeded()
                }
                
                UIView.animate(withDuration: 0.48, delay: 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1) {
                    genreStatsView.transform = .init(translationX: 0, y: -250)
                } completion: { _ in
                    gravityContainerView.isHidden = false
                    var views = [UIView]()
                    bounce = UIDynamicItemBehavior()
                    bounce?.resistance = 0
                    bounce?.elasticity = 0.7
                    for _ in 0...4 {
                        let song = Shared.Song(name: "WAP", artists: ["Cardi B"], albumArt: .local(UIImage.from(color: .systemPink)), thumbnailAlbumArt: .local(UIImage.from(color: .systemBlue)), geniusURL: nil)
                        let newView = GenreMapSongView.fromNib
                        newView.frame.origin = gravityProducerView.bounds.randomPointInRect
                        gravityContainerView.addSubview(newView)
                        newView.configure(with: GenreMapSongViewModel(song: song))
                        newView.layoutSubviews()
                        newView.frame.size.width = newView.songViewFrame.size.width
                        newView.transform = CGAffineTransform(rotationAngle: CGFloat(Float.random(in: -0.65...0.65) * .pi))
                        newView.didTap = {
                            flowLyrics?(song, newView.previewImage)
                        }
                        views.append(newView)
                        bounce?.addItem(newView)
                        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(pan:)))
                        pan.cancelsTouchesInView = false
                        banSnap = false
                        newView.addGestureRecognizer(pan)
                    }
                    animator = UIDynamicAnimator(referenceView: gravityContainerView)
//                    animator?.setValue(true, forKey: "debugEnabled")
                    gravity = UIGravityBehavior(items: views)
                    gravity?.magnitude = 3
                    animator?.addBehavior(gravity!)
                    animator?.addBehavior(bounce!)
                    collision = UICollisionBehavior(items: views)
                    collision?.translatesReferenceBoundsIntoBoundary = true
                    collision?.collisionDelegate = self
                    animator?.addBehavior(collision!)
                    
                    push = UIPushBehavior(items: gravityContainerView.subviews.filter { $0.isKind(of: GenreMapSongView.self) }, mode: .instantaneous)
                    push?.pushDirection = CGVector(dx: 0, dy: 25)
                    push?.magnitude = 15
                    animator?.addBehavior(push!)
                    delay(1) {
                        if let push = push {
                            animator?.removeBehavior(push)
                            self.push = nil
                        }
                    }
                }
                
                UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseIn) {
                    genreStatsView.alpha = 1
                }
            }.dispose(in: disposeBag)
            
            button.reactive.controlEvents([.touchDown, .touchDragEnter]).observeNext { [self] in
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                    var rotationWithPerspective = CATransform3DIdentity
                    rotationWithPerspective.m34 = -1.0 / 1000.0
                    let angle = [4, 5, 6, 7].contains(index) ? 0.05 * CGFloat.pi : -0.05 * CGFloat.pi
                    genreMapBackgroundView.layer.transform = CATransform3DRotate(rotationWithPerspective, angle, transforms[index].0, transforms[index].1, 0)
                }
            }.dispose(in: disposeBag)
            
            button.reactive.controlEvents(.touchDragExit).observeNext { [self] in
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                    genreMapBackgroundView.layer.transform = CATransform3DIdentity
                }
            }.dispose(in: disposeBag)
            
            let dashedViewBorder = CAShapeLayer()
            dashedViewBorder.strokeColor = Asset.Colors.gravityTipGrey.color.cgColor
            dashedViewBorder.lineDashPattern = [22, 18]
            dashedViewBorder.frame = dashedView.bounds
            dashedViewBorder.fillColor = nil
            dashedViewBorder.lineWidth = 4
            dashedViewBorder.path = UIBezierPath.superellipse(in: dashedView.bounds, cornerRadius: 60).cgPath
            dashedView.layer.addSublayer(dashedViewBorder)
        }
        
        uprightWarningView.isHidden = true
        uprightWarningView.alpha = 0
    }
    
    @IBAction private func backButtonTapped() {
        navigationItem.title = "genremap"
        if let button = navigationItem.leftBarButtonItem?.customView as? UIButton {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                button.alpha = 0
            } completion: { [self] _ in
                navigationItem.rightBarButtonItem = nil
            }
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut) { [self] in
            descriptionLabel.layer.transform = CATransform3DIdentity
        }
        
        descriptionLabel.alpha = 0
        UIView.animate(withDuration: 0.35, delay: 0.2, options: .curveEaseOut) { [self] in
            descriptionLabel.alpha = 1
        }
        
        UIView.animate(withDuration: 0.48, delay: 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1) { [self] in
            genreStatsView.transform = .init(translationX: 0, y: -600)
        }
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseIn) { [self] in
            genreStatsView.alpha = 0
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) { [self] in
            genreMapBackgroundView.layer.transform = CATransform3DIdentity
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) { [self] in
            genreMapBackgroundView.alpha = 1
        }
        
        genreMapBackgroundView.isUserInteractionEnabled = false
        
        collision?.translatesReferenceBoundsIntoBoundary = false
        collision?.removeAllBoundaries()
        if let push = push {
            animator?.removeBehavior(push)
            self.push = nil
        }
        push = UIPushBehavior(items: gravityContainerView.subviews.filter { $0.isKind(of: GenreMapSongView.self) }, mode: .instantaneous)
        push?.pushDirection = gravity?.gravityDirection ?? CGVector(dx: 0, dy: 20)
        push?.magnitude = 15
        banSnap = true
        animator?.addBehavior(push!)
        if let gravity = gravity {
            animator?.removeBehavior(gravity)
            self.gravity = nil
        }
        UIView.animate(withDuration: 1) { [self] in
            gravityContainerView.alpha = 0
        } completion: { [self] _ in
            gravityContainerView.alpha = 1
        }
        delay(1) { [self] in
            gravityContainerView.isHidden = true
            gravityContainerView.subviews.forEach { $0.removeFromSuperview() }
            
            genreMapBackgroundView.isUserInteractionEnabled = true
            if let push = push {
                animator?.removeBehavior(push)
                self.push = nil
            }
        }
    }
    
    @IBAction private func onPan(pan: UIPanGestureRecognizer) {
        guard let songView = pan.view, !banSnap else { return }
        
        if pan.state == .changed || pan.state == .began {
            if let snap = snap {
                animator?.removeBehavior(snap)
            }
            snap = UISnapBehavior(item: songView, snapTo: pan.location(in: gravityContainerView))
            animator?.addBehavior(snap!)
        }
        if pan.state == .ended || pan.state == .cancelled {
            if let snap = snap {
                animator?.removeBehavior(snap)
                self.snap = nil
            }
        }
        
    }
    
    @IBAction private func motionRefresh() {
        
        if let acceleration = motionManager?.deviceMotion?.userAcceleration {
            if let pushAccelerometer = pushAccelerometer {
                animator?.removeBehavior(pushAccelerometer)
                self.pushAccelerometer = nil
            }
            pushAccelerometer = UIPushBehavior(items: gravityContainerView.subviews.filter { $0.isKind(of: GenreMapSongView.self) }, mode: .instantaneous)
            pushAccelerometer?.pushDirection = CGVector(dx: acceleration.x * 3, dy: acceleration.y * 3)
    //                pushAccelerometer?.magnitude = 1
            animator?.addBehavior(pushAccelerometer!)
        }
        
        guard let quat = motionManager?.deviceMotion?.attitude.quaternion else { return }
        let xFormula = asin(2*(quat.x*quat.z - quat.w*quat.y))
        let yFormula = atan2(2 * (quat.w * quat.x + quat.y * quat.z), 1 - 2 * (quat.x * quat.x + quat.y * quat.y))
        
        if self.motionLastX == 0 {
            self.motionLastX = xFormula
        }
        
        if self.motionLastY == 0 {
            self.motionLastY = yFormula
        }

        var x = self.motionLastX
        GenreMapViewController.px += GenreMapViewController.qx
        GenreMapViewController.kx = GenreMapViewController.px / (GenreMapViewController.px + GenreMapViewController.rx)
        x += GenreMapViewController.kx*(xFormula - x)
        GenreMapViewController.px = (1 - GenreMapViewController.kx)*GenreMapViewController.px
        self.motionLastX = x
        
        var y = self.motionLastY
        GenreMapViewController.py += GenreMapViewController.qy
        GenreMapViewController.ky = GenreMapViewController.py / (GenreMapViewController.py + GenreMapViewController.ry)
        y += GenreMapViewController.ky*(yFormula - y)
        GenreMapViewController.py = (1 - GenreMapViewController.ky)*GenreMapViewController.py
        self.motionLastY = y
        
        gravity?.gravityDirection = CGVector(dx: -x * 3, dy: y * 3)
//        gravity?.magnitude = 2
        
        if gravity != nil && y < 0.1 && uprightWarningView.isHidden {
            uprightWarningView.isHidden = false
            uprightWarningView.alpha = 0
            UIView.animate(withDuration: 0.3) { [self] in
                uprightWarningView.alpha = 1
            }
            hidView = false
        } else if gravity == nil || (y > 0.1 && !uprightWarningView.isHidden && !hidView) {
            hidView = true
            uprightWarningView.alpha = 1
            UIView.animate(withDuration: 0.3) { [self] in
                uprightWarningView.alpha = 0
            } completion: { [self] _ in
                uprightWarningView.isHidden = true
            }
        }
    }
    
}

extension GenreMapViewController: TranslationAnimationView {
    
    var translationViews: [UIView] {
        []
    }
    
    var translationInteractor: TranslationAnimationInteractor? { nil }
    
}

// swiftlint:disable identifier_name
extension GenreMapViewController: UICollisionBehaviorDelegate {
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item1: UIDynamicItem, with item2: UIDynamicItem, at p: CGPoint) {
        collider.on(.next(()))
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        collider.on(.next(()))
    }
    
}
