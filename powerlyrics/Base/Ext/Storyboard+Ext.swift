//
//  Storyboard+Ext.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import UIKit

public protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension ViewController: StoryboardIdentifiable { }

extension StoryboardIdentifiable where Self: ViewController {
    
    public static var storyboardIdentifier: String {
        String(describing: self)
    }
    
}

extension UIStoryboard {
    
    public static func createController<T: ViewController>(_: T.Type) -> T {
        let storyboard = UIStoryboard(name: T.storyboardIdentifier, bundle: nil)
        return storyboard.instantiateViewController(T.self)
    }
    
    public func instantiateViewController<T: ViewController>(_: T.Type) -> T {
        guard let viewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("View controller with \(T.storyboardIdentifier) not found")
        }
        
        return viewController
    }
    
    public func instantiateViewController<T: ViewController>() -> T {
        guard let viewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("View controller with \(T.storyboardIdentifier) not found")
        }
        
        return viewController
    }
    
}
