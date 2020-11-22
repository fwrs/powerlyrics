//
//  SetupOfflineViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

// MARK: - Constants

extension Constants {
    
    static var unsuitableForMinorsAlert: UIAlertController {
        UIAlertController(
            title: Strings.Setup.Under18.title,
            message: Strings.Setup.Under18.message,
            preferredStyle: .alert
        )
    }
    
    static var failedToSignInAlert: UIAlertController {
        UIAlertController(
            title: Strings.Setup.NetworkFailed.title,
            message: Strings.Setup.NetworkFailed.message,
            preferredStyle: .alert
        )
    }
    
}

fileprivate extension Constants {
    
    static let keyboardOffsets: (CGFloat, CGFloat, CGFloat) = (2, 17, 30)
    
    static var enterNameAlert: UIAlertController {
        UIAlertController(
            title: Strings.Setup.NameEmpty.title,
            message: Strings.Setup.NameEmpty.message,
            preferredStyle: .alert
        )
    }
    
}

// MARK: - SetupOfflineViewController

class SetupOfflineViewController: ViewController, SetupOfflineScene {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var brandingStackView: UIStackView!
    
    @IBOutlet private weak var buttonsStackView: UIStackView!
    
    @IBOutlet private weak var formStackView: UIStackView!
    
    @IBOutlet private weak var mainButton: LoadingButton!
    
    @IBOutlet private weak var nameTextField: UITextField!
    
    @IBOutlet private weak var over18Switch: UISwitch!
    
    // MARK: - Instance properties
    
    var viewModel: SetupOfflineViewModel!
    
    var translationInteractor: TranslationAnimationInteractor?
    
    // MARK: - Flows
    
    var flowDismiss: DefaultAction?
    
    var flowSpotifyLoginOffline: DefaultAction?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupView()
        setupInput()
        setupOutput()
        
        addKeyboardWillShowNotification()
        addKeyboardWillHideNotification()
        addKeyboardDidHideNotification()
        
        nameTextField.delegate = self
        
    }
    
    // MARK: - Actions
    
    override func keyboardWillShow(notification: Notification) {
        super.keyboardWillShow(notification: notification)
        
        UIView.animate { [weak self] in
            self?.brandingStackView.transform = .init(translationX: .zero, y: -(UIScreen.main.bounds.height / Constants.keyboardOffsets.2))
            self?.formStackView.transform = .init(translationX: .zero, y: -(UIScreen.main.bounds.height / Constants.keyboardOffsets.1))
            self?.buttonsStackView.transform = .init(translationX: .zero, y: UIScreen.main.bounds.height / Constants.keyboardOffsets.0)
        }
        translationInteractor?.gesture?.isEnabled = false
    }
    
    override func keyboardWillHide(notification: Notification) {
        super.keyboardWillHide(notification: notification)
        
        UIView.animate { [weak self] in
            self?.brandingStackView.transform = .identity
            self?.formStackView.transform = .identity
            self?.buttonsStackView.transform = .identity
        }
    }

    override func keyboardDidHide(notification: Notification) {
        super.keyboardDidHide(notification: notification)
        
        translationInteractor?.gesture?.isEnabled = true
    }
    
    // MARK: - Helper methods
    
    func show(error: SetupOfflineError) {
        
        switch error {
        case .network(.networkFailed):
            present(Constants.failedToSignInAlert.with {
                $0.addAction(UIAlertAction(title: Constants.ok, style: .default, handler: nil))
            }, animated: true, completion: nil)
            
        case .validation(.nameEmpty):
            present(Constants.enterNameAlert.with {
                $0.addAction(UIAlertAction(title: Constants.ok, style: .default, handler: nil))
            }, animated: true, completion: nil)
            
        case .validation(.under18):
            present(Constants.unsuitableForMinorsAlert.with {
                $0.addAction(UIAlertAction(title: Constants.ok, style: .default, handler: nil))
            }, animated: true, completion: nil)
        }
        
    }
    
}

// MARK: - Setup

extension SetupOfflineViewController {
    
    // MARK: - View

    func setupView() {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.standardAppearance = appearance
        
        translationInteractor = TranslationAnimationInteractor(viewController: self, pop: true)
        
    }

    // MARK: - Input

    func setupInput() {
        
        mainButton.reactive.tap.observeNext { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.login(
                name: self.nameTextField.text.safe.typographized,
                over18: self.over18Switch.isOn
            )
        }.dispose(in: disposeBag)
        
    }
    
    // MARK: - Output
    
    func setupOutput() {
        
        viewModel.loginState.observeNext { [weak self] result in
            switch result {
            case .ok(let isLoading):
                self?.mainButton.isLoading = isLoading
                if !isLoading {
                    self?.flowDismiss?()
                }
                
            case .fail(let error):
                self?.show(error: error)
            }
        }.dispose(in: disposeBag)
        
    }
    
}

// MARK: - TranslationAnimationView

extension SetupOfflineViewController: TranslationAnimationView {
    
    var translationViews: [UIView] {
        [brandingStackView]
    }

}

// MARK: - UITextFieldDelegate

extension SetupOfflineViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
}
