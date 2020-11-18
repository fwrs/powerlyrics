//
//  SetupOfflineViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

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
        setupObservers()
        
        addKeyboardWillShowNotification()
        addKeyboardWillHideNotification()
        addKeyboardDidHideNotification()
        
        nameTextField.delegate = self
        
    }
    
    // MARK: - Actions
    
    override func keyboardWillShow(notification: Notification) {
        super.keyboardWillShow(notification: notification)
        UIView.animate(withDuration: 0.2) { [self] in
            brandingStackView.transform = .init(translationX: 0, y: -(UIScreen.main.bounds.height / 30))
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
            if nameTextField.text.safe.isEmpty {
                present(UIAlertController(title: "Please enter your name", message: "In order to register we need to know your name and whether you’re older than 18 years old.", preferredStyle: .alert).with {
                    $0.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                }, animated: true, completion: nil)
                return
            }
            if !over18Switch.isOn {
                present(UIAlertController(title: "Unsuitable for minors", message: "You have to be over 18 years old in order to use this app.", preferredStyle: .alert).with {
                    $0.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                }, animated: true, completion: nil)
                return
            }
            viewModel.saveLocalUserData(name: nameTextField.text.safe, over18: over18Switch.isOn)
            mainButton.isLoading = true
            viewModel.spotifyProvider.loginWithoutUser { success in
                delay(2) {
                    mainButton.isLoading = false
                }
                if success {
                    flowSpotifyLoginOffline?()
                    if let homeViewController = ((window.rootViewController as? UITabBarController)?.viewControllers?.first as? Router)?.viewControllers.first as? HomeViewController {
                        homeViewController.viewModel.loadData()
                        homeViewController.viewModel.checkSpotifyAccount()
                    }
                    if let profileViewController = ((window.rootViewController as? UITabBarController)?.viewControllers?.last as? Router)?.viewControllers.first as? ProfileViewController {
                        profileViewController.viewModel.updateData()
                    }
                } else {
                    mainButton.isLoading = false
                    present(UIAlertController(title: "Failed to sign in", message: "Please try again.", preferredStyle: .alert).with {
                        $0.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    }, animated: true, completion: nil)
                    viewModel.fail()
                }
            }
        }.dispose(in: disposeBag)
    }
    
}

extension SetupOfflineViewController: TranslationAnimationView {
    
    var translationViews: [UIView] {
        [brandingStackView]
    }

}

extension SetupOfflineViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
