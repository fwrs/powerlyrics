//
//  LoadingButton.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
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

class LoadingButton: UIButton {
    
    var isLoading: Bool = false {
        didSet {
            changeLoadingState(isLoading: isLoading)
        }
    }
    
    private(set) var activityView: UIActivityIndicatorView = .init(style: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configure()
    }
    
    private func configure() {
        activityView.hidesWhenStopped = true
        self.addSubview(activityView)

        NSLayoutConstraint.activate([
            activityView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func changeLoadingState(isLoading: Bool) {
        isEnabled = !isLoading
        
        UIView.animate(withDuration: 0.3) {
            self.titleLabel?.alpha = isLoading ? 0 : 1
        }
        
        if isLoading {
            activityView.startAnimating()
        } else {
            activityView.stopAnimating()
        }
    }
    
}
