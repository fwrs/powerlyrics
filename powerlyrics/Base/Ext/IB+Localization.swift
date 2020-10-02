//
//  IB+Localization.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import UIKit

extension UILabel {
    
    @IBInspectable var localizedTextKey: String? {
        get { nil }
        set(key) {
            if let key = key {
                text = NSLocalizedString(key, comment: "")
            } else {
                text = nil
            }
        }
    }
    
}

extension UIButton {
    
    @IBInspectable var localizedNormalTitleKey: String? {
        get { nil }
        set(key) {
            if let key = key {
                setTitle(NSLocalizedString(key, comment: ""), for: .normal)
            } else {
                setTitle(nil, for: .normal)
            }
            
        }
    }
    
}

extension UITextField {
    
    @IBInspectable var localizedPlaceholderKey: String? {
        get { nil }
        set(key) {
            if let key = key {
                placeholder = NSLocalizedString(key, comment: "")
            } else {
                placeholder = nil
            }
        }
    }
    
    @IBInspectable var localizedTextKey: String? {
        
        get { nil }
        set(key) {
            if let key = key {
                text = NSLocalizedString(key, comment: "")
            } else {
                text = nil
            }
        }
    }
    
}

extension UINavigationItem {
    
    @IBInspectable var localizedTitleKey: String? {
        get { nil }
        set(key) {
            if let key = key {
                title = NSLocalizedString(key, comment: "")
            } else {
                title = nil
            }
        }
    }
    
}

extension UITabBarItem {
    
    @IBInspectable var localizedTitleKey: String? {
        get { nil }
        set(key) {
            if let key = key {
                title = NSLocalizedString(key, comment: "")
            } else {
                title = nil
            }
        }
    }
    
}

extension UIViewController {
    
    @IBInspectable var localizedTitleKey: String? {
        get { nil }
        set(key) {
            if let key = key {
                title = NSLocalizedString(key, comment: "")
            } else {
                title = nil
            }
        }
    }
    
}

extension UISearchBar {
    
    @IBInspectable var localizedPlaceholderKey: String? {
        get { nil }
        set(key) {
            if let key = key {
                placeholder = NSLocalizedString(key, comment: "")
            } else {
                placeholder = nil
            }
        }
    }
    
}

extension UIBarButtonItem {
    
    @IBInspectable var localizedTitleKey: String? {
        get { nil }
        set(key) {
            if let key = key {
                title = NSLocalizedString(key, comment: "")
            } else {
                title = nil
            }
        }
    }
    
}

extension UISegmentedControl {
    
    @IBInspectable var localizedTitlesKey: String? {
        get { nil }
        set(key) {
            if let key = key {
                key.components(separatedBy: ",").enumerated().forEach { i, title in
                    setTitle(title, forSegmentAt: i)
                }
            }
        }
    }
    
}
