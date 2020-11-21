//
//  UnpaddedTextView.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/21/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

class UnpaddedTextView: UITextView {
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupView()
    }
    
    override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        super.setContentOffset(contentOffset, animated: false)
    }
    
    // MARK: - Setup view
    
    func setupView() {
        textContainerInset = .zero
        textContainer.lineFragmentPadding = .zero
    }
    
}
