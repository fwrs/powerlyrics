//
//  ProfileCoordinator.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//

import Swinject
import UIKit

class ProfileCoordinator: Coordinator {
    
    let router: Router

    init(router: Router, resolver: Resolver) {
        self.router = router
        super.init(resolver: resolver)
    }
    
    override func start() {
        let scene = resolver.resolve(ProfileScene.self)
        router.push(scene, animated: false)
    }
    
    override var rootViewController: UIViewController {
        router
    }
    
}
