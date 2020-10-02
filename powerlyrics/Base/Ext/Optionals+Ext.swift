//
//  Optionals+Ext.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Foundation
import UIKit

extension Optional where Wrapped == String {
    
    var safe: Wrapped {
        switch self {
        case .none:
            return ""
        case .some(let value):
            return value
        }
    }
    
}

extension Optional where Wrapped == Int {
    
    var safe: Wrapped {
        switch self {
        case .none:
            return 0
        case .some(let value):
            return value
        }
    }
    
}

extension Optional where Wrapped == Float {
    
    var safe: Wrapped {
        switch self {
        case .none:
            return 0
        case .some(let value):
            return value
        }
    }
    
}

extension Optional where Wrapped == Double {
    
    var safe: Wrapped {
        switch self {
        case .none:
            return 0
        case .some(let value):
            return value
        }
    }
    
}

extension Optional where Wrapped == Bool {
    
    var safe: Wrapped {
        switch self {
        case .none:
            return false
        case .some(let value):
            return value
        }
    }
    
}

extension Optional where Wrapped == CGFloat {
    
    var safe: Wrapped {
        switch self {
        case .none:
            return 0
        case .some(let value):
            return value
        }
    }
    
}
