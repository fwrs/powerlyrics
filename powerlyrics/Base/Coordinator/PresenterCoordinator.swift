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
    
    func clearChildren<T: Coordinator>(_: T.Type)
    
}

extension Coordinator: PresenterCoordinator {
    
    func clearChildren<T>(_: T.Type) where T: Coordinator {
        
        childCoordinators.removeAll { $0.isKind(of: T.self) }
        
    }
    
}
