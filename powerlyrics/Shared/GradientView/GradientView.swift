//
//  GradientView.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 15.11.20.
//

import UIKit

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
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        } else if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            gradientLayer.startPoint = CGPoint(x: 1, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0)
        }
    }
    
}
