//
//  GenreMapViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Haptica
import ReactiveKit

// MARK: - Constants

extension Constants {
    
    static let baseLikedSongCounts: [CGFloat] = Array(repeating: 0, count: RealmLikedSongGenre.total)
    
}

fileprivate extension Constants {
    
    static let descriptionText = Strings.GenreMap.description
    static let likedMusicButtonText = Strings.GenreMap.Description.likedMusic

    static let transforms: [(CGFloat, CGFloat)] = [(1, 0), (1, 1), (0, 1), (-1, 1), (1, 0), (1, 1), (0, 1), (-1, 1)]
    static let inverseAngles = 4...7
    
    static let backgroundAppearanceDuration: TimeInterval = 0.9
    static let descriptionAppearanceDuration: TimeInterval = 0.55
    static let buttonAppearanceBaseDuration: TimeInterval = 0.5
    static let noDataAppearanceDuration: TimeInterval = 0.6
    static let flipDuration: TimeInterval = 0.4
    static let tinyDelay: TimeInterval = 0.05
    static let descriptionAppearanceDelay: TimeInterval = 0.45
    static let flipPerspective: CGFloat = -1 / 500.0
    static let smallAngleMultiplier: CGFloat = 0.025
    static let largeAngleMultiplier: CGFloat = 0.2
    static let concealedGenreMapAlpha: CGFloat = 0.8
    static let springDamping: CGFloat = 0.6
    
    static let descriptionParagraphStyle = NSMutableParagraphStyle().with {
        $0.lineSpacing = 2
    }
    
    static let delayFunction = { (i: Int) in
        (0.1 + Constants.tinyDelay * Double(i) + pow(0.95, Double(i)) / 20) }
    
}

// MARK: - GenreMapViewController

class GenreMapViewController: ViewController, GenreMapScene {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var genreMapBackgroundView: GenreMapBackgroundView!
    
    @IBOutlet private weak var genreMapView: GenreMapView!
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    @IBOutlet private weak var notEnoughDataView: UIView!
    
    @IBOutlet private weak var secondaryMapAlignmentConstraint: NSLayoutConstraint!
    
    @IBOutlet private var genreMapButtons: [UIButton]!
    
    // MARK: - Instance properties
    
    var viewModel: GenreMapViewModel!
    
    var shouldAnimate: Bool = true
    
    var goingBackFromPush: Bool = false
    
    var justAnimatedReappear: Bool = false
    
    // MARK: - Flows
    
    var flowGenre: DefaultRealmLikedSongGenreAction?
    
    var flowLikedSongs: DefaultAction?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupInput()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.loadData()
        animate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        restore()
    }
        
    // MARK: - Helper methods
    
    func animate() {
        
        genreMapView.values = viewModel.values.value
        let noData = viewModel.noData.value
        
        if shouldAnimate {
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseOut) { [weak self] in
                self?.genreMapBackgroundView.alpha = 1
            }
            
            UIView.animate(withDuration: Constants.backgroundAppearanceDuration, delay: Constants.fastAnimationDuration, options: .curveEaseOut) { [weak self] in
                self?.genreMapView.alpha = 1
            }
            
            delay(Constants.fastAnimationDuration) { [weak self] in
                self?.genreMapView.animatePathChange()
            }
            
            for i in 0..<RealmLikedSongGenre.total {
                UIView.animate(withDuration: Constants.buttonAppearanceBaseDuration + (Double(i) * 0.1), delay: Constants.delayFunction(i), options: .curveEaseOut) { [weak self] in
                    self?.genreMapButtons[i].alpha = 1
                }
            }
            
            UIView.animate(withDuration: Constants.descriptionAppearanceDuration, delay: noData ? Constants.tinyDelay : Constants.descriptionAppearanceDelay, options: .curveEaseIn) { [weak self] in
                self?.descriptionLabel.alpha = 1
            }
            
            if noData {
                notEnoughDataView.isHidden = false
                notEnoughDataView.alpha = 0
                UIView.animate(withDuration: Constants.noDataAppearanceDuration, delay: Constants.tinyDelay, options: .curveEaseOut) { [weak self] in
                    self?.notEnoughDataView.alpha = 1
                }
            } else {
                notEnoughDataView.isHidden = true
            }
            
            shouldAnimate = false
        } else {
            if (notEnoughDataView.isHidden && noData) || (!notEnoughDataView.isHidden && !noData) {
                if noData {
                    notEnoughDataView.isHidden = false
                    notEnoughDataView.alpha = 0
                } else {
                    notEnoughDataView.alpha = 1
                }
                
                UIView.animate(withDuration: 0.5) { [weak self] in
                    self?.notEnoughDataView.alpha = noData ? 1 : 0
                } completion: { [weak self] _ in
                    if !noData {
                        self?.notEnoughDataView.isHidden = true
                    }
                }
            }
            genreMapView.animatePathChange(fast: true)
        }
        
        goingBackFromPush = false
        
    }

    func restore() {
        
        if goingBackFromPush {
            UIView.animate { [weak self] in
                self?.genreMapBackgroundView.alpha = 1
                self?.genreMapBackgroundView.layer.transform = CATransform3DIdentity
            }
        }
        
    }
    
    func generateAttributedDescriptionText(highlight: Bool = false) -> NSMutableAttributedString {
        
        let attrString = NSMutableAttributedString(string: Constants.descriptionText)
        
        attrString.addAttribute(
            .paragraphStyle,
            value: Constants.descriptionParagraphStyle,
            range: NSRange(location: 0, length: attrString.length)
        )
        
        attrString.addAttribute(
            .foregroundColor,
            value: highlight ? UIColor.highlightTintColor : UIColor.tintColor,
            range: NSString(string: Constants.descriptionText).range(of: Constants.likedMusicButtonText)
        )
        
        return attrString
        
    }
    
}

// MARK: - Setup

extension GenreMapViewController {
    
    // MARK: - View

    func setupView() {
        
        if !UIDevice.current.hasNotch {
            secondaryMapAlignmentConstraint.isActive = true
        }

        descriptionLabel.attributedText = generateAttributedDescriptionText()
        
        ([genreMapBackgroundView, genreMapView, descriptionLabel, notEnoughDataView] + genreMapButtons).forEach { view in
            view?.alpha = 0
        }
        
    }
    
    // MARK: - Input
    
    func setupInput() {
        
        genreMapButtons.enumerated().forEach { index, button in
            button.reactive.tap.observeNext { [weak self] in
                guard let self = self else { return }
                
                var rotationWithPerspective = CATransform3DIdentity
                rotationWithPerspective.m34 = Constants.flipPerspective
                let angle = Constants.inverseAngles.contains(index).sign * -Constants.largeAngleMultiplier * CGFloat.pi
                
                UIView.animate(withDuration: Constants.flipDuration, delay: 0, usingSpringWithDamping: Constants.springDamping, initialSpringVelocity: 2) { [weak self] in
                    self?.genreMapBackgroundView.layer.transform =
                        CATransform3DRotate(rotationWithPerspective, angle, Constants.transforms[index].0, Constants.transforms[index].1, 0)
                    self?.genreMapBackgroundView.alpha = Constants.concealedGenreMapAlpha
                }
                
                Haptic.play(Constants.tinyTap)
                self.flowGenre?(RealmLikedSongGenre(rawValue: index) ?? .unknown)
                self.goingBackFromPush = true
            }.dispose(in: disposeBag)
            
            button.reactive.controlEvents([.touchDown, .touchDragEnter]).observeNext { [weak self] in
                UIView.animate(withDuration: Constants.flipDuration, delay: 0, usingSpringWithDamping: Constants.springDamping, initialSpringVelocity: 1) {
                    var rotationWithPerspective = CATransform3DIdentity
                    rotationWithPerspective.m34 = Constants.flipPerspective
                    let angle = Constants.inverseAngles.contains(index).sign * Constants.smallAngleMultiplier * CGFloat.pi
                    self?.genreMapBackgroundView.layer.transform = CATransform3DRotate(rotationWithPerspective, angle, Constants.transforms[index].0, Constants.transforms[index].1, 0)
                }
            }.dispose(in: disposeBag)
            
            button.reactive.controlEvents(.touchDragExit).observeNext { [weak self] in
                UIView.animate(withDuration: Constants.flipDuration, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0) {
                    self?.genreMapBackgroundView.layer.transform = CATransform3DIdentity
                }
            }.dispose(in: disposeBag)
        }
        
        descriptionLabel.reactive.longPressGesture(minimumPressDuration: 0).observeNext { [weak self] recognizer in
            guard let self = self else { return }
            if recognizer.state == .ended || recognizer.state == .cancelled {
                UIView.fadeUpdate(self.descriptionLabel, duration: Constants.buttonTapDuration) { [weak self] in
                    self?.descriptionLabel.attributedText = self?.generateAttributedDescriptionText()
                }
            }
            
            switch recognizer.state {
            case .began:
                UIView.fadeUpdate(self.descriptionLabel, duration: Constants.buttonTapDuration) { [weak self] in
                    self?.descriptionLabel.attributedText = self?.generateAttributedDescriptionText(highlight: true)
                }
                
            case .ended:
                Haptic.play(Constants.tinyTap)
                self.flowLikedSongs?()
                
            default:
                break
            }
        }.dispose(in: disposeBag)
        
    }
    
}
