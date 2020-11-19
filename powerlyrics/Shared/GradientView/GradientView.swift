//
//  GradientView.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/15/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

// MARK: - Constants

fileprivate extension Constants {
    
    static let gradientBeginPoint = CGPoint.zero
    static let gradientEndPoint = CGPoint(x: CGFloat.one, y: .zero)
    
}

// MARK: - GradientView

class GradientView: UIView {
    
    override open class var layerClass: AnyClass {
        CAGradientLayer.classForCoder()
    }
    
    var gradientLayer: CAGradientLayer {
        layer as! CAGradientLayer
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gradientLayer = layer as! CAGradientLayer
        if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
            gradientLayer.startPoint = Constants.gradientBeginPoint
            gradientLayer.endPoint = Constants.gradientEndPoint
        } else if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            gradientLayer.startPoint = Constants.gradientEndPoint
            gradientLayer.endPoint = Constants.gradientBeginPoint
        }
    }
    
}
