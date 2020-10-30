//
//  Misc.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//

import Haptica
import Moya
import Typographizer

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

extension Haptic {
    
    static func play(_ pattern: String) {
        Haptic.play(pattern, delay: 0.1)
    }
    
}

extension NSObject {
    
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

extension Data {

    var nonEmpty: Bool {
        !isEmpty
    }
    
    var string: String {
        String(data: self, encoding: .utf8).safe
    }
    
}

extension Array {

    var nonEmpty: Bool {
        !isEmpty
    }
    
}

extension String {
    
    var nonEmpty: Bool {
        !isEmpty
    }
    
    var url: URL? {
        URL(string: self)
    }
    
    var clean: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var typographized: String {
        typographized(language: NSLocale.current.languageCode ?? "en")
    }
    
}

extension Substring {
    
    var nonEmpty: Bool {
        !isEmpty
    }
    
    var url: URL? {
        URL(string: String(self))
    }
    
    var clean: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var string: String {
        String(self)
    }
    
}

extension CGFloat {
    
    var radians: CGFloat {
        CGFloat.pi * (self / 180)
    }
    
}

extension UIDevice {
    
    var hasNotch: Bool {
        UIApplication.shared.windows.first { $0.isKeyWindow }!.safeAreaInsets.bottom > 0
    }
    
}

extension Dictionary where Key == String {

    var httpCompatible: String {
        String(
            self.reduce("") { "\($0)&\($1.key)=\($1.value)" }
                .replacingOccurrences(of: " ", with: "+")
                .dropFirst()
        )
    }
    
}

extension URL {

    func with(parameters: String) -> URL? {
        URL(string: "\(self.absoluteString)?\(parameters)")
    }

    func with(parameters: [String: Any]) -> URL? {
        URL(string: "\(self.absoluteString)?\(parameters.httpCompatible)")
    }
    
}

extension Array where Element: Equatable {
    
    func dedup() -> [Element] {
        var result = [Element]()

        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }

        return result
    }
    
    func dedupNearby(equals value: Element) -> [Element] {
        var previousElement: Element?
        
        return reduce(into: []) { total, element in
            defer {
                previousElement = element
            }
            if previousElement == element && value == element {
                return
            }
            total.append(element)
        }
    }
    
}
