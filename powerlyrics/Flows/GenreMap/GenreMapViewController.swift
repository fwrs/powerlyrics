//
//  GenreMapViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//

import UIKit

class GenreMapViewController: ViewController, GenreMapScene {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var genreMapBackgroundView: GenreMapBackgroundView!
    
    @IBOutlet private weak var genreMapView: GenreMapView!
    
    @IBOutlet private var genreMapButtons: [UIButton]!
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    // MARK: - Instance properties
    
    var viewModel: GenreMapViewModel!
    
    var shouldAnimate: Bool = true
    
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
    }
    
    // MARK: - Actions
    
}

extension GenreMapViewController {
    
    // MARK: - Setup

    func setupView() {}
    
}
