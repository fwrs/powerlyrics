//
//  View.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/5/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

class View: UIView {
    
    static var fromNib: Self {
        if let view = nib.instantiate(withOwner: nil, options: nil).first as? Self {
            return view
        }
        assertionFailure("Nib \(nibName) not loaded")
        return Self()
    }
    
}

private extension View {

    static var nib: UINib {
        UINib(nibName: nibName, bundle: nibBundle)
    }

    static var nibName: String {
        String(describing: self)
    }

    static var nibBundle: Bundle? {
        Bundle(for: self)
    }
    
}
