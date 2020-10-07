//
//  SetupOfflineViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//

import UIKit

class SetupOfflineViewController: ViewController, SetupOfflineScene {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var brandingStackView: UIStackView!
    
    @IBOutlet private weak var buttonsStackView: UIStackView!
    
    @IBOutlet private weak var formStackView: UIStackView!
    
    @IBOutlet private weak var mainButton: UIButton!
    
    // MARK: - Instance properties
    
    var viewModel: SetupOfflineViewModel!
    
    var translationInteractor: TranslationAnimationInteractor?
    
    // MARK: - Flows
    
    var flowDismiss: DefaultAction?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupObservers()
        
        addKeyboardWillShowNotification()
        addKeyboardWillHideNotification()
        addKeyboardDidHideNotification()
    }
    
    // MARK: - Actions
    
    override func keyboardWillShow(notification: Notification) {
        super.keyboardWillShow(notification: notification)
        UIView.animate(withDuration: 0.2) { [self] in
            brandingStackView.transform = .init(translationX: 0, y: -(UIScreen.main.bounds.height / 17))
            formStackView.transform = .init(translationX: 0, y: -(UIScreen.main.bounds.height / 17))
            buttonsStackView.transform = .init(translationX: 0, y: UIScreen.main.bounds.height / 2)
        }
        translationInteractor?.gesture?.isEnabled = false
    }
    
    override func keyboardWillHide(notification: Notification) {
        super.keyboardWillHide(notification: notification)
        UIView.animate(withDuration: 0.2) { [self] in
            brandingStackView.transform = .identity
            formStackView.transform = .identity
            buttonsStackView.transform = .identity
        }
    }

    override func keyboardDidHide(notification: Notification) {
        super.keyboardDidHide(notification: notification)
        translationInteractor?.gesture?.isEnabled = true
    }
    
}

extension SetupOfflineViewController {
    
    // MARK: - Setup

    func setupView() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.standardAppearance = appearance
        
        translationInteractor = TranslationAnimationInteractor(viewController: self, pop: true)
    }
    
    func setupObservers() {
        mainButton.reactive.tap.observeNext { [self] _ in
            flowDismiss?()
        }.dispose(in: disposeBag)
    }
    
}

extension SetupOfflineViewController: TranslationAnimationView {
    
    var translationViews: [UIView] {
        [brandingStackView]
    }

}
