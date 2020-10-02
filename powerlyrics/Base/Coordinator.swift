//
//  Coordinator.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Foundation

import Swinject

class Coordinator: NSObject {
    
    var childCoordinators: [Coordinator] = []
    
    let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
    }
    
    func start() {
        
    }
    
    var rootViewController: UIViewController {
        fatalError("Inaccessible")
    }
    
}
