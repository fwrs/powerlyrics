//
//  NoInternetView.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/15/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit
import UIKit

// MARK: - Constants

extension Constants {
    
    static let buttonTapDuration: TimeInterval = 0.08
    
    static let tryAgainText = "try again"
    
}

// MARK: - NoInternetView

class NoInternetView: View {
    
    // MARK: - Outlets

    @IBOutlet private weak var noInternetImageView: UIImageView!
    
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    // MARK: - Instance properties
    
    let disposeBag = DisposeBag()
    
    var onRefresh: DefaultAction?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        noInternetImageView.image = noInternetImageView.image?.withTintColor(.label, renderingMode: .alwaysOriginal)
        let text = subtitleLabel.text.safe.typographized

        let attrString = NSMutableAttributedString(string: text)
        
        attrString.addAttribute(.foregroundColor, value: UIColor.tintColor, range: NSString(string: text).range(of: Constants.tryAgainText))
        subtitleLabel.attributedText = attrString
        
        subtitleLabel.reactive.longPressGesture(minimumPressDuration: 0).observeNext { [self] recognizer in
            if recognizer.state == .ended || recognizer.state == .cancelled {
                let attrString = NSMutableAttributedString(string: text)
                
                attrString.addAttribute(.foregroundColor, value: UIColor.tintColor, range: NSString(string: text).range(of: Constants.tryAgainText))
                
                UIView.transition(with: subtitleLabel, duration: Constants.buttonTapDuration, options: .transitionCrossDissolve) {
                    subtitleLabel.attributedText = attrString
                }
            }
            
            switch recognizer.state {
            case .began:
                let attrString = NSMutableAttributedString(string: text)
                
                attrString.addAttribute(.foregroundColor, value: UIColor.highlightTintColor, range: NSString(string: text).range(of: Constants.tryAgainText))
                
                UIView.transition(with: subtitleLabel, duration: Constants.buttonTapDuration, options: .transitionCrossDissolve) {
                    subtitleLabel.attributedText = attrString
                }
            case .ended:
                onRefresh?()
            default:
                break
            }
        }.dispose(in: disposeBag)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if view == subtitleLabel {
            return view
        } else {
            return nil
        }
    }

}
