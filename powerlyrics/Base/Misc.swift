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
        for _ in 0..<n {
            execute()
        }
    }
}

extension Collection {
    
    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
    
}

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

extension Array {
    
    func dedup(where predicate: @escaping (Element, Element) throws -> Bool) rethrows -> [Element] {
        var buffer: [Element] = []

        for element in self {
            
            if try buffer.contains(where: { try predicate(element, $0) }) {
                continue
            }

            buffer.append(element)
        }

        return buffer
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
        self == 1 ? .init() : Constants.englishPlural
    }
    
}

extension UIColor {
    
    func adjust(hueBy hue: CGFloat = 1, saturationBy saturation: CGFloat = 1, brightnessBy brightness: CGFloat = 1, minBrightness: CGFloat = 0) -> UIColor {
        var currentHue: CGFloat = 0
        var currentSaturation: CGFloat = 0
        var currentBrigthness: CGFloat = 0
        var currentAlpha: CGFloat = 0
        
        if getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrigthness, alpha: &currentAlpha) {
            return UIColor(hue: currentHue * hue,
                           saturation: currentSaturation * saturation,
                           brightness: max(currentBrigthness * brightness, minBrightness),
                           alpha: currentAlpha)
        } else {
            return self
        }
    }
    
    var transparent: UIColor {
        withAlphaComponent(0)
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
    
    private enum ExtensionConstants {
        
        static let activityIndicatorDimension: CGFloat = 20
        static let viewHeight: CGFloat = 70
        
        static let loadingFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        static let contentViewControllerKeyPath = "contentViewController"
        
    }

    func addLoadingUI(title: String) {
        let vc = UIViewController()
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        NSLayoutConstraint.activate([
            activityIndicator.widthAnchor.constraint(equalToConstant: ExtensionConstants.activityIndicatorDimension)
        ])
        let label = UILabel()
        label.text = title
        label.font = ExtensionConstants.loadingFont
        let stackView = UIStackView(arrangedSubviews: [activityIndicator, label])
        stackView.spacing = Constants.space8
        stackView.axis = .horizontal
        stackView.alignment = .center
        vc.preferredContentSize = CGSize(width: label.intrinsicContentSize.width + ExtensionConstants.activityIndicatorDimension + Constants.space8, height: ExtensionConstants.viewHeight)
        stackView.frame = CGRect(x: 0, y: 0, width: label.intrinsicContentSize.width + ExtensionConstants.activityIndicatorDimension + Constants.space8, height: ExtensionConstants.viewHeight)
        vc.view.addSubview(stackView)
        label.sizeToFit()
        self.setValue(vc, forKey: ExtensionConstants.contentViewControllerKeyPath)
    }

    func dismissActivityIndicator() {
        self.setValue(nil, forKey: ExtensionConstants.contentViewControllerKeyPath)
        self.dismiss(animated: false)
    }
    
}

extension UIView {
    
    private enum ExtensionConstants {
        
        static let alphaChangeKeyPath = "alphaChange"
        static let opacityKeyPath = "opacity"
        
    }
    
    class func fadeShow(_ view: UIView, duration: TimeInterval = Constants.defaultAnimationDuration, completion: DefaultAction? = nil) {
        fadeDisplay(view, visible: true, duration: duration, completion: completion)
    }
    
    class func fadeHide(_ view: UIView, duration: TimeInterval = Constants.defaultAnimationDuration, completion: DefaultAction? = nil) {
        fadeDisplay(view, visible: false, duration: duration, completion: completion)
    }
    
    class func fadeDisplay(_ view: UIView, visible: Bool, duration: TimeInterval = Constants.defaultAnimationDuration, completion: DefaultAction? = nil) {
        let currentAlpha = view.alpha
        CATransaction.begin()
        view.layer.removeAnimation(forKey: ExtensionConstants.alphaChangeKeyPath)
        view.isUserInteractionEnabled = false
        let animation = CABasicAnimation(keyPath: ExtensionConstants.opacityKeyPath)
        animation.fromValue = view.isHidden ? 0 : currentAlpha
        if visible {
            view.isHidden = false
        }
        animation.toValue = visible ? 1 : 0
        animation.duration = duration
        animation.fillMode = .forwards
        CATransaction.setCompletionBlock {
            view.isHidden = !visible
            view.isUserInteractionEnabled = true
            completion?()
        }
        view.alpha = visible ? 1 : 0
        view.layer.add(animation, forKey: ExtensionConstants.alphaChangeKeyPath)
        CATransaction.commit()
    }
    
    class func fadeUpdate(_ view: UIView, duration: TimeInterval = Constants.defaultAnimationDelay, changes: DefaultAction?, completion: DefaultAction? = nil) {
        transition(with: view, duration: duration, options: .transitionCrossDissolve) {
            changes?()
        } completion: { _ in
            completion?()
        }
    }
    
    class func animate(withDuration duration: TimeInterval, options: UIView.AnimationOptions = [], animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: completion)
    }
    
    class func animate(options: UIView.AnimationOptions = [], animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        animate(withDuration: Constants.defaultAnimationDuration, delay: 0, options: options, animations: animations, completion: completion)
    }
    
}

extension Optional where Wrapped == String {
    
    var mapEmptyToNil: Self {
        
        if self?.isEmpty == true {
            return nil
        } else {
            return self
        }
        
    }
    
}
