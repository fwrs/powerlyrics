//
//  UIColor+Ext.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import UIKit

extension UIColor {

    @nonobjc class var tintColor: UIColor {
        Asset.Colors.tintColor.color
    }

    @nonobjc class var darkTintColor: UIColor {
        Asset.Colors.darkTintColor.color
    }

}