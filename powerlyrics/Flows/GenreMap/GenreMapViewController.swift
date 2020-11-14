//
//  GenreMapViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//

import CoreMotion
import Haptica
import ReactiveKit
import RealmSwift
import Then
import UIKit

class GenreMapViewController: ViewController, GenreMapScene {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var genreMapBackgroundView: GenreMapBackgroundView!
    
    @IBOutlet private weak var genreMapView: GenreMapView!
    
    @IBOutlet private var genreMapButtons: [UIButton]!
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    @IBOutlet private weak var notEnoughDataView: UIView!
    
    @IBOutlet private weak var secondaryMapAlignmentConstraint: NSLayoutConstraint!
    
    // MARK: - Instance properties
    
    var viewModel: GenreMapViewModel!
    
    var shouldAnimate: Bool = true
    
    var goingBackFromPush: Bool = false
    
    var justAnimatedReappear: Bool = false
    
    var noData: Bool = false
    
    // MARK: - Flows
    
    var flowGenre: DefaultRealmLikedSongGenreAction?
    
    var flowLikedSongs: DefaultAction?
    
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
        notEnoughDataView.alpha = 0
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
            if noData {
                notEnoughDataView.isHidden = false
                notEnoughDataView.alpha = 0
                UIView.animate(withDuration: 0.7, delay: 0.55, options: .curveEaseOut) { [self] in
                    notEnoughDataView.alpha = 1
                }
            } else {
                notEnoughDataView.isHidden = true
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
        
        descriptionLabel.reactive.longPressGesture(minimumPressDuration: 0).observeNext { [self] recognizer in
            if recognizer.state == .ended || recognizer.state == .cancelled {
                let attrString = NSMutableAttributedString(string: text)
                attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attrString.length))
                
                attrString.addAttribute(.foregroundColor, value: UIColor.tintColor, range: NSString(string: text).range(of: "liked music"))
                
                UIView.transition(with: descriptionLabel, duration: 0.08, options: .transitionCrossDissolve) {
                    descriptionLabel.attributedText = attrString
                }
            }
            
            switch recognizer.state {
            case .began:
                let attrString = NSMutableAttributedString(string: text)
                attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attrString.length))
                
                attrString.addAttribute(.foregroundColor, value: UIColor.highlightTintColor, range: NSString(string: text).range(of: "liked music"))
                
                UIView.transition(with: descriptionLabel, duration: 0.08, options: .transitionCrossDissolve) {
                    descriptionLabel.attributedText = attrString
                }
            case .ended:
                flowLikedSongs?()
            default:
                break
            }
        }.dispose(in: disposeBag)
        
        genreMapButtons.enumerated().forEach { index, button in
            button.reactive.tap.observeNext { [self] in
                var rotationWithPerspective = CATransform3DIdentity
                rotationWithPerspective.m34 = -1.0 / 500.0
                let angle = [4, 5, 6, 7].contains(index) ? -0.2 * CGFloat.pi : 0.2 * CGFloat.pi
                
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1) {
                    genreMapBackgroundView.layer.transform =
                        CATransform3DRotate(rotationWithPerspective, angle, transforms[index].0, transforms[index].1, 0)
                    genreMapBackgroundView.alpha = 0.8
                }
                
                flowGenre?(RealmLikedSongGenre(rawValue: index) ?? .unknown)
                goingBackFromPush = true
            }.dispose(in: disposeBag)
            
            button.reactive.controlEvents([.touchDown, .touchDragEnter]).observeNext { [self] in
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1) {
                    var rotationWithPerspective = CATransform3DIdentity
                    rotationWithPerspective.m34 = -1.0 / 1000.0
                    let angle = [4, 5, 6, 7].contains(index) ? 0.05 * CGFloat.pi : -0.05 * CGFloat.pi
                    genreMapBackgroundView.layer.transform = CATransform3DRotate(rotationWithPerspective, angle, transforms[index].0, transforms[index].1, 0)
                }
            }.dispose(in: disposeBag)
            
            button.reactive.controlEvents(.touchDragExit).observeNext { [self] in
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0) {
                    genreMapBackgroundView.layer.transform = CATransform3DIdentity
                }
            }.dispose(in: disposeBag)
            
            let total = ([.rock, .classic, .rap, .country, .acoustic, .pop, .jazz, .edm]
                .map { CGFloat(Realm.likedSongs(with: $0).count) } + [0.0001]).max().safe
            
            let counts = [Realm.likedSongs(with: .rock).count,
                          Realm.likedSongs(with: .classic).count,
                          Realm.likedSongs(with: .rap).count,
                          Realm.likedSongs(with: .country).count,
                          Realm.likedSongs(with: .acoustic).count,
                          Realm.likedSongs(with: .pop).count,
                          Realm.likedSongs(with: .jazz).count,
                          Realm.likedSongs(with: .edm).count]

            if counts.filter({ $0 != 0 }).count < 2 {
                noData = true
                genreMapView.values = [Int](0..<8).map { _ in 0 }
            } else {
                genreMapView.values = [
                    CGFloat(Realm.likedSongs(with: .rock).count) / total,
                    CGFloat(Realm.likedSongs(with: .classic).count) / total,
                    CGFloat(Realm.likedSongs(with: .rap).count) / total,
                    CGFloat(Realm.likedSongs(with: .country).count) / total,
                    CGFloat(Realm.likedSongs(with: .acoustic).count) / total,
                    CGFloat(Realm.likedSongs(with: .pop).count) / total,
                    CGFloat(Realm.likedSongs(with: .jazz).count) / total,
                    CGFloat(Realm.likedSongs(with: .edm).count) / total
                ].map { max(0.012, $0) }
            }
        }
    }
    
}
