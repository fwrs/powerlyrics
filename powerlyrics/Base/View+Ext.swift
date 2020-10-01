//
//  View+Ext.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import UIKit

extension UIView {
    
    var safeAreaRect: CGRect {
        CGRect(
            x: safeAreaInsets.left,
            y: safeAreaInsets.top,
            width: frame.width - safeAreaInsets.left - safeAreaInsets.right,
            height: frame.height - safeAreaInsets.top - safeAreaInsets.bottom
        )
    }
    
    func mask() {
        layer.masksToBounds = true
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        mask()
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func roundCorners(radius: CGFloat) {
        mask()
        layer.cornerRadius = radius
    }
    
    func squircleCorners(radius: CGFloat) {
        mask()
        layer.cornerRadius = radius
        layer.cornerCurve = CALayerCornerCurve.continuous
    }
    
}
