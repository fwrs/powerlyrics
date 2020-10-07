//
//  SetupManualViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//

import UIKit

class SetupManualViewController: ViewController, SetupManualScene {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var mainButton: UIButton!
    
    @IBOutlet private weak var secondaryButton: UIButton!
    
    // MARK: - Instance properties
    
    var viewModel: SetupManualViewModel!
    
    // MARK: - Flows
    
    var flowDismiss: DefaultAction?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupObservers()
    }
    
    // MARK: - Actions
    
}

extension SetupManualViewController {
    
    // MARK: - Setup

    func setupView() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.standardAppearance = appearance
    }
    
    func setupObservers() {
        secondaryButton.reactive.tap.observeNext { [self] _ in
            flowDismiss?()
        }.dispose(in: disposeBag)
    }
    
}
