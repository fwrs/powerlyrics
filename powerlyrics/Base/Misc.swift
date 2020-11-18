//
//  Misc.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Haptica
import Moya
import Typographizer

func delay(_ seconds: TimeInterval, execute: @escaping DefaultAction) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: execute)
}

func times(_ n: Int) -> (DefaultAction) -> Void {
    { execute in
        for _ in .zero..<n {
            execute()
        }
    }
}

let twice = times(.two)

let thrice = times(.three)

extension Collection {
    
    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
    
}

extension Haptic {
    
    static func play(_ pattern: String) {
        Haptic.play(pattern, delay: .pointOne)
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

extension CGRect {
    
    var randomPointInRect: CGPoint {
        let origin = self.origin
        return CGPoint(x: CGFloat(arc4random_uniform(UInt32(self.width))) + origin.x, y: CGFloat(arc4random_uniform(UInt32(self.height))) + origin.y)
    }
    
}

extension FloatingPointSign {
    
    var number: CGFloat {
        self == .plus ? 1 : -1
    }
    
}

extension UIWindow {
    
    var topViewController: UIViewController? {
        var top = self.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }
    
}

extension Bool {
    
    var negated: Bool {
        !self
    }
    
    var sign: CGFloat {
        self ? 1 : -1
    }
    
}

extension Int {
    
    var sIfNotOne: String {
        self == 1 ? .init() : "s"
    }
    
}

extension UIColor {
    
    func adjust(hueBy hue: CGFloat = .one, saturationBy saturation: CGFloat = .one, brightnessBy brightness: CGFloat = .one) -> UIColor {
        var currentHue = CGFloat.zero
        var currentSaturation = CGFloat.zero
        var currentBrigthness = CGFloat.zero
        var currentAlpha = CGFloat.zero
        
        if getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrigthness, alpha: &currentAlpha) {
            return UIColor(hue: currentHue * hue,
                           saturation: currentSaturation * saturation,
                           brightness: currentBrigthness * brightness,
                           alpha: currentAlpha)
        } else {
            return self
        }
    }
    
    var transparent: UIColor {
        withAlphaComponent(.zero)
    }
    
    var cg: CGColor {
        cgColor
    }
    
}

public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    private static var _allButOnceTracker = [String]()
    
    class func once(file: String = #file,
                           function: String = #function,
                           line: Int = #line,
                           block: () -> Void) {
        let token = "\(file):\(function):\(line)"
        once(token: token, block: block)
    }
    
    class func allButOnce(file: String = #file,
                           function: String = #function,
                           line: Int = #line,
                           block: () -> Void) {
        let token = "\(file):\(function):\(line)"
        allButOnce(token: token, block: block)
    }
    
    class func once(token: String,
                           block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        guard !_onceTracker.contains(token) else { return }
        
        _onceTracker.append(token)
        block()
    }
    
    class func allButOnce(token: String,
                           block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        guard _allButOnceTracker.contains(token) else {
            _allButOnceTracker.append(token)
            return
        }
        
        block()
    }

}

extension UIAlertController {

    func addLoadingUI(title: String) {
        let vc = UIViewController()
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        NSLayoutConstraint.activate([
            activityIndicator.widthAnchor.constraint(equalToConstant: 20)
        ])
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        let stackView = UIStackView(arrangedSubviews: [activityIndicator, label])
        stackView.spacing = 8
        stackView.axis = .horizontal
        stackView.alignment = .center
        vc.preferredContentSize = CGSize(width: label.intrinsicContentSize.width + 28, height: 70)
        stackView.frame = CGRect(x: .zero, y: .zero, width: label.intrinsicContentSize.width + 28, height: 70)
        vc.view.addSubview(stackView)
        label.sizeToFit()
        self.setValue(vc, forKey: "contentViewController")
    }

    func dismissActivityIndicator() {
        self.setValue(nil, forKey: "contentViewController")
        self.dismiss(animated: false)
    }
    
}

extension UIView {
    
    func fadeShow(duration: TimeInterval = Constants.defaultAnimationDuration, completion: DefaultAction? = nil) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve) { [self] in
            isHidden = false
        } completion: { _ in
            completion?()
        }
    }
    
    func fadeHide(duration: TimeInterval = Constants.defaultAnimationDuration, completion: DefaultAction? = nil) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve) { [self] in
            isHidden = true
        } completion: { _ in
            completion?()
        }
    }
    
    func fadeDisplay(visible: Bool, duration: TimeInterval = Constants.defaultAnimationDuration, completion: DefaultAction? = nil) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve) { [self] in
            isHidden = !visible
        } completion: { _ in
            completion?()
        }
    }
    
    func fadeUpdate(duration: TimeInterval = Constants.defaultAnimationDelay, changes: DefaultAction?, completion: DefaultAction? = nil) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve) {
            changes?()
        } completion: { _ in
            completion?()
        }
    }
    
    class func animate(withDuration duration: TimeInterval, options: UIView.AnimationOptions = [], animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: .zero, options: options, animations: animations, completion: completion)
    }
    
    class func animate(options: UIView.AnimationOptions = [], animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: Constants.defaultAnimationDuration, delay: .zero, options: options, animations: animations, completion: completion)
    }
    
}

extension Int {
    
    static var one: Int {
        1
    }
    
    static var two: Int {
        2
    }
    
    static var three: Int {
        3
    }
    
}

extension Float {
    
    static var fourth: Float {
        0.25
    }
    
    static var half: Float {
        0.5
    }
    
    static var threeFourths: Float {
        0.75
    }
    
    static var pointOne: Float {
        0.1
    }
    
    static var pointTwo: Float {
        0.2
    }
    
    static var pointThree: Float {
        0.3
    }
    
    static var one: Float {
        1
    }
    
    static var oneHalfth: Float {
        1.5
    }
    
    static var two: Float {
        2
    }
    
    static var three: Float {
        3
    }
    
}

extension Double {
    
    static var fourth: Double {
        0.25
    }
    
    static var half: Double {
        0.5
    }
    
    static var threeFourths: Double {
        0.75
    }
    
    static var pointOne: Double {
        0.1
    }
    
    static var pointTwo: Double {
        0.2
    }
    
    static var pointThree: Double {
        0.3
    }
    
    static var one: Double {
        1
    }
    
    static var oneHalfth: Double {
        1.5
    }
    
    static var two: Double {
        2
    }
    
    static var three: Double {
        3
    }
    
}

extension CGFloat {
    
    static var fourth: CGFloat {
        0.25
    }
    
    static var half: CGFloat {
        0.5
    }
    
    static var threeFourths: CGFloat {
        0.75
    }
    
    static var pointOne: CGFloat {
        0.1
    }
    
    static var pointTwo: CGFloat {
        0.2
    }
    
    static var pointThree: CGFloat {
        0.3
    }
    
    static var one: CGFloat {
        1
    }
    
    static var oneHalfth: CGFloat {
        1.5
    }
    
    static var two: CGFloat {
        2
    }
    
    static var three: CGFloat {
        3
    }
    
}
