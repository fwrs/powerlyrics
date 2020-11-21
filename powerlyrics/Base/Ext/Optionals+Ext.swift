//
//  Optionals+Ext.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

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

extension Optional where Wrapped == UIColor {
    
    var safe: Wrapped {
        switch self {
        case .none:
            return .clear
            
        case .some(let value):
            return value
        }
    }
    
}
