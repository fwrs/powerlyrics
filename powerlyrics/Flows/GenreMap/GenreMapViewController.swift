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
    
    // MARK: - Instance properties
    
    var viewModel: GenreMapViewModel!
    
    var shouldAnimate: Bool = true
    
    var goingBackFromPush: Bool = false
    
    var justAnimatedReappear: Bool = false
    
    // MARK: - Flows
    
    var flowGenre: DefaultLikedSongGenreAction?
    
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
        
        goingBackFromPush = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if goingBackFromPush {
            UIView.animate(withDuration: 0.3) { [self] in
                genreMapBackgroundView.alpha = 1
                genreMapBackgroundView.layer.transform = CATransform3DIdentity
            }
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
        
        let text = descriptionLabel.text.safe.typographized
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2

        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attrString.length))
        
        attrString.addAttribute(.foregroundColor, value: UIColor.tintColor, range: NSString(string: text).range(of: "liked music"))
        
        descriptionLabel.attributedText = attrString
        
        let transforms: [(CGFloat, CGFloat)] = [(1, 0), (1, 1), (0, 1), (-1, 1), (1, 0), (1, 1), (0, 1), (-1, 1)]
        
        genreMapButtons.enumerated().forEach { index, button in
            button.reactive.tap.observeNext { [self] in
                var rotationWithPerspective = CATransform3DIdentity
                rotationWithPerspective.m34 = -1.0 / 500.0
                let angle = [4, 5, 6, 7].contains(index) ? -0.2 * CGFloat.pi : 0.2 * CGFloat.pi
                
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
                    genreMapBackgroundView.layer.transform =
                        CATransform3DRotate(rotationWithPerspective, angle, transforms[index].0, transforms[index].1, 0)
                    genreMapBackgroundView.alpha = 0.8
                }
                
                flowGenre?(LikedSongGenre(rawValue: index) ?? .unknown)
                goingBackFromPush = true
            }.dispose(in: disposeBag)
            
            button.reactive.controlEvents([.touchDown, .touchDragEnter]).observeNext { [self] in
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
                    var rotationWithPerspective = CATransform3DIdentity
                    rotationWithPerspective.m34 = -1.0 / 1000.0
                    let angle = [4, 5, 6, 7].contains(index) ? 0.05 * CGFloat.pi : -0.05 * CGFloat.pi
                    genreMapBackgroundView.layer.transform = CATransform3DRotate(rotationWithPerspective, angle, transforms[index].0, transforms[index].1, 0)
                }
            }.dispose(in: disposeBag)
            
            button.reactive.controlEvents(.touchDragExit).observeNext { [self] in
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
                    genreMapBackgroundView.layer.transform = CATransform3DIdentity
                }
            }.dispose(in: disposeBag)
        }
    }
    
}
