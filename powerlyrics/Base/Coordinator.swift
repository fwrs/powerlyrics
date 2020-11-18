//
//  Coordinator.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Swinject

class Coordinator: NSObject {
    
    var childCoordinators: [Coordinator] = []
    
    let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
    }
    
    func start() {}
    
    var rootViewController: UIViewController {
        fatalError("Inaccessible")
    }
    
}
