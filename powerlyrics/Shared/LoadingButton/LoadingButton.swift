//
//  LoadingButton.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit
import UIKit

extension ReactiveExtensions where Base: LoadingButton {

    var isLoading: Bond<Bool> {
        bond { (el, val) in
            if val {
                el.isLoading = true
            } else {
                el.isLoading = false
            }
        }
    }
    
}

// MARK: - LoadingButton

class LoadingButton: UIButton {

    // MARK: - Instance properties

    var isLoading: Bool = false {
        didSet {
            changeLoadingState(isLoading: isLoading)
        }
    }
    
    private var storedTitleColor: UIColor?
    
    private(set) var activityView: UIActivityIndicatorView = .init(style: .medium)
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configure()
    }
    
    // MARK: - Setup
    
    private func configure() {
        activityView.hidesWhenStopped = true
        self.addSubview(activityView)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        activityView.color = .white
        bringSubviewToFront(activityView)
        NSLayoutConstraint.activate([
            activityView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        storedTitleColor = titleColor(for: .normal)
    }
    
    // MARK: - Helper functions
    
    private func changeLoadingState(isLoading: Bool) {
        isEnabled = !isLoading
        
        UIView.transition(with: self, duration: 0.1, options: .transitionCrossDissolve) { [self] in
            setTitleColor(isLoading ? .clear : (storedTitleColor ?? .label), for: .normal)
        }
        
        if isLoading {
            activityView.startAnimating()
        } else {
            activityView.stopAnimating()
        }
    }
    
}
