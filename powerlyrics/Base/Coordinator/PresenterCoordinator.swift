//
//  PresenterCoordinator.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/19/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

// MARK: - PresenterCoordinator

protocol PresenterCoordinator: AnyObject {
    
    func clearChild<T: Coordinator>(_: T.Type)
    
}

extension Coordinator: PresenterCoordinator {
    
    func clearChild<T>(_: T.Type) where T: Coordinator {
        
        let lastIndex = childCoordinators.lastIndex { $0.isKind(of: T.self) }

        if let index = lastIndex {
            childCoordinators.remove(at: index)
        }
        
    }
    
}
