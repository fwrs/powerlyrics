//
//  Coordinator.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Foundation

import Swinject

class Coordinator: NSObject, CoordinatorProtocol {
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
    }
    
    func start() {
        
    }
    
}
