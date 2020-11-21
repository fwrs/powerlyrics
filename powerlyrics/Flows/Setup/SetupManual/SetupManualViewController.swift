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
    
    // MARK: - Instance properties
    
    var selfOrSafari: UIViewController {
        presentedViewController ?? self
    }
    
    var viewModel: SetupSharedSpotifyViewModel!

    var loadingAlert: UIAlertController?
    
    // MARK: - Flows
    
    var flowDismiss: DefaultAction?
    
    var flowSpotifyLogin: DefaultAction?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupInput()
        setupOutput()
        
        _ = NotificationCenter.default.addObserver(
            forName: .appDidOpenURL,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            guard let self = self, let url = notification.userInfo?[NotificationKey.url] as? URL,
                  self.navigationController?.topViewController == self else { return }
            self.viewModel.appDidOpenURL(url: url)
        }
    }
    
    // MARK: - Helper methods

    func show(error: LoginError) {
        switch error {
        case .networkError:
            selfOrSafari.present(Constants.failedToSignInAlert.with {
                $0.addAction(UIAlertAction(title: Constants.ok, style: .default, handler: { [weak self] _ in
                    self?.presentedViewController?.dismiss(animated: true, completion: nil)
                }))
            }, animated: true, completion: nil)
            
        case .underage:
            selfOrSafari.present(Constants.unsuitableForMinorsAlert.with {
                $0.addAction(UIAlertAction(title: Constants.ok, style: .default, handler: { [weak self] _ in
                    self?.presentedViewController?.dismiss(animated: true, completion: nil)
                }))
            }, animated: true, completion: nil)
        }
    }
    
    func setLoading(visible: Bool, completion: DefaultAction? = nil) {
        if !visible {
            loadingAlert?.dismiss(animated: true, completion: completion)
            loadingAlert = nil
            return
        }
        
        let loadingAlert = UIAlertController(title: nil, message: nil, preferredStyle: .alert).with {
            $0.addLoadingUI(title: Constants.pleaseWaitText)
        }
        
        selfOrSafari.present(loadingAlert, animated: true, completion: completion)
        self.loadingAlert = loadingAlert
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
        mainButton.reactive.tap.throttle(for: Constants.buttonThrottleTime).observeNext { [weak self] _ in
            self?.flowSpotifyLogin?()
        }.dispose(in: disposeBag)
        
        secondaryButton.reactive.tap.throttle(for: Constants.buttonThrottleTime).observeNext { [weak self] _ in
            self?.flowDismiss?()
        }.dispose(in: disposeBag)
    }
    
    // MARK: - Output
    
    func setupOutput() {
        
        viewModel.loginState.observeNext { [weak self] result in
            switch result {
            case .ok(let isLoading):
                self?.setLoading(visible: isLoading)
                if !isLoading {
                    self?.flowDismiss?()
                }
                
            case .fail(let error):
                self?.setLoading(visible: false) {
                    self?.show(error: error)
                }
            }
        }.dispose(in: disposeBag)
        
    }
    
}
