//
//  CopyableLabel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/21/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

class CopyableLabel: UILabel {

    // MARK: - Instance properties
    
    override public var canBecomeFirstResponder: Bool {
        get {
            true
        }
    }
    
    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    // MARK: - Setup
    
    func setupView() {
        isUserInteractionEnabled = true
        
        addGestureRecognizer(UILongPressGestureRecognizer(
            target: self,
            action: #selector(showMenu(sender:))
        ))
    }
    
    // MARK: - Actions

    @objc private func showMenu(sender: Any?) {
        becomeFirstResponder()
        
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            UIMenuController.shared.showMenu(from: self, rect: bounds)
        }
    }
    
    // MARK: - MenuController

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        action == #selector(copy(_:))
    }
    
    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
        UIMenuController.shared.hideMenu(from: self)
    }
    
}
