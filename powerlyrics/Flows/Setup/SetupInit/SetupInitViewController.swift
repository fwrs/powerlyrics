//
//  SetupInitViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

class SetupInitViewController: ViewController, SetupInitScene {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var mainButton: UIButton!
    
    @IBOutlet private weak var secondaryButton: UIButton!
    
    @IBOutlet private weak var brandingStackView: UIStackView!
    
    @IBOutlet private weak var buttonsStackView: UIStackView!
    
    // MARK: - Instance properties
    
    var viewModel: SetupInitViewModel!
    
    // MARK: - Flows
    
    var flowDismiss: DefaultAction?
    
    var flowSpotifyLogin: DefaultAction?
    
    var flowOfflineSetup: DefaultAction?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupObservers()
    }
    
    // MARK: - Actions
    
    // MARK: - Helper methods
    
}

extension SetupInitViewController {
    
    // MARK: - Setup

    func setupView() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.standardAppearance = appearance
    }
    
    func setupObservers() {
        mainButton.reactive.tap.throttle(for: 0.3).observeNext { [self] _ in
            flowSpotifyLogin?()
        }.dispose(in: disposeBag)
        secondaryButton.reactive.tap.throttle(for: 0.3).observeNext { [self] _ in
            flowOfflineSetup?()
        }.dispose(in: disposeBag)
    }
    
}

extension SetupInitViewController: TranslationAnimationView {
    
    var translationViews: [UIView] {
        [brandingStackView]
    }
    
    var translationInteractor: TranslationAnimationInteractor? { nil }

    var completelyMoveAway: Bool { true }
    
}
