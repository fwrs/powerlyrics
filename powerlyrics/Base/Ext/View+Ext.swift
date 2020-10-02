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
    
    func mask(_ shouldMask: Bool = true) {
        layer.masksToBounds = shouldMask
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func roundCorners(radius: CGFloat) {
        layer.cornerRadius = radius
    }
    
    func squircleCorners(radius: CGFloat) {
        layer.cornerRadius = radius
        layer.cornerCurve = CALayerCornerCurve.continuous
    }
    
    func shadow(
        ofColor color: UIColor,
        radius: CGFloat,
        offset: CGSize = .zero,
        opacity: Float = 0.5,
        spread: Float = 0
    ) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        mask(false)
        if spread == 0 {
            layer.shadowPath = nil
        } else {
            let dx = CGFloat(-spread)
            let rect = layer.bounds.insetBy(dx: dx, dy: dx)
            layer.shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
    
}
