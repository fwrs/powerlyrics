//
//  HomeCoordinator.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Swinject
import UIKit

class HomeCoordinator: Coordinator {
    
    let router: Router

    init(router: Router, resolver: Resolver) {
        self.router = router
        super.init(resolver: resolver)
    }
    
    func showSample() {
        print("ok")
    }
    
    override func start() {
        let scene = resolver.resolve(HomeScene.self)
        scene?.flowSample = { [weak self] in
            self?.showSample()
        }
        router.push(scene, animated: false)
    }
    
    override var rootViewController: UIViewController {
        router
    }
    
}
