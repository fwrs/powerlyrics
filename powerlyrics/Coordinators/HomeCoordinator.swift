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
    
    func showLyrics(for song: Song) {
        let lyricsCoordinator = resolver.resolve(LyricsCoordinator.self, arguments: Router(), rootViewController, { [self] in
            childCoordinators.removeAll { $0.isKind(of: LyricsCoordinator.self) }
        }, song)!
        childCoordinators.append(lyricsCoordinator)
        lyricsCoordinator.start()
    }
    
    override func start() {
        let scene = resolver.resolve(HomeScene.self)
        scene?.flowLyrics = { [weak self] song in
            self?.showLyrics(for: song)
        }
        router.push(scene, animated: false)
    }
    
    override var rootViewController: UIViewController {
        router
    }
    
}
