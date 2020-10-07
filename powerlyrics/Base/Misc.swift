//
//  Misc.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//

import Foundation
import Haptica

func delay(_ seconds: TimeInterval, execute: @escaping DefaultAction) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: execute)
}

func times(_ n: Int) -> (DefaultAction) -> Void {
    { execute in
        for _ in 0..<n {
            execute()
        }
    }
}

let twice = times(2)

let thrice = times(3)

public extension Haptic {
    
    static func play(_ pattern: String) {
        Haptic.play(pattern, delay: 0.1)
    }
    
}

public extension NSObject {
    
    func safeValue(forKey key: String) -> Any? {
        let copy = Mirror(reflecting: self)
        
        for child in copy.children.makeIterator() {
            if let label = child.label, label == key {
                return child.value
            }
        }
        
        return nil
    }
    
}

public extension String {
    
    var nonEmpty: Bool {
        !isEmpty
    }
    
}

extension CGFloat {
    var radians: CGFloat {
        CGFloat.pi * (self / 180)
    }
}

extension RangeReplaceableCollection {
    
    mutating func rotateRight(positions: Int) {
        let index = self.index(endIndex, offsetBy: -positions, limitedBy: startIndex) ?? startIndex
        let slice = self[index...]
        removeSubrange(index...)
        insert(contentsOf: slice, at: startIndex)
    }
    
}
