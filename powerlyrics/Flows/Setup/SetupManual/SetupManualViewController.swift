//
//  SetupManualViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

// MARK: - SetupManualViewController

class SetupManualViewController: ViewController, SetupManualScene {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var mainButton: UIButton!
    
    @IBOutlet private weak var secondaryButton: UIButton!
    
    // MARK: - Flows
    
    var flowDismiss: DefaultAction?
    
    var flowSpotifyLogin: DefaultAction?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupInput()
    }
    
}

// MARK: - Setup

extension SetupManualViewController {
    
    // MARK: - View

    func setupView() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.standardAppearance = appearance
    }
    
    // MARK: - Input

    func setupInput() {
        mainButton.reactive.tap.throttle(for: Constants.buttonThrottleTime).observeNext { [self] _ in
            flowSpotifyLogin?()
        }.dispose(in: disposeBag)
        
        secondaryButton.reactive.tap.throttle(for: Constants.buttonThrottleTime).observeNext { [self] _ in
            flowDismiss?()
        }.dispose(in: disposeBag)
    }
    
}
