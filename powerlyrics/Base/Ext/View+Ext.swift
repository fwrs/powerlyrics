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
        layer.cornerRadius = radius + 1
        layer.cornerCurve = CALayerCornerCurve.continuous
    }
    
    func shadow(
        color: UIColor,
        radius: CGFloat,
        offset: CGSize = .zero,
        opacity: Float = 0.5,
        spread: CGFloat = 0,
        viewCornerRadius: CGFloat = 0,
        viewSquircle: Bool = false
    ) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        if spread == 0 {
            layer.shadowPath = nil
        } else {
            let dx = CGFloat(-spread)
            let rect = layer.bounds.insetBy(dx: dx, dy: dx)
            layer.shadowPath = UIBezierPath(rect: rect).cgPath
        }
        if viewCornerRadius != 0 {
            if viewSquircle {
                layer.shadowPath = UIBezierPath.superellipse(in: bounds, cornerRadius: CGFloat(viewCornerRadius + 1)).cgPath
            } else {
                layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: CGFloat(viewCornerRadius)).cgPath
            }
        }
    }
    
}

// MARK: - IB

extension UIView {
    
    @IBInspectable var roundCorners: CGFloat {
        get {
            layer.cornerRadius
        }
        set {
            roundCorners(radius: newValue)
        }
    }
    
    @IBInspectable var squircleCorners: CGFloat {
        get {
            layer.cornerRadius
        }
        set {
            squircleCorners(radius: newValue)
        }
    }
    
}
