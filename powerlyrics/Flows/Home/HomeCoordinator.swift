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
    
    func showLyrics(for song: Shared.Song, placeholder: UIImage?) {
        let lyricsCoordinator = resolver.resolve(LyricsCoordinator.self, arguments: Router(), rootViewController, { [self] in
            childCoordinators.removeAll { $0.isKind(of: LyricsCoordinator.self) }
        }, song, placeholder)!
        childCoordinators.append(lyricsCoordinator)
        lyricsCoordinator.start()
    }
    
    func showSetup(mode: SetupMode) {
        let setupCoordinator = resolver.resolve(SetupCoordinator.self, arguments: Router(), rootViewController, { [self] in
            childCoordinators.removeAll { $0.isKind(of: SetupCoordinator.self) }
        }, mode)!
        childCoordinators.append(setupCoordinator)
        setupCoordinator.start()
    }
    
    override func start() {
        let scene = resolver.resolve(HomeScene.self)
        scene?.flowLyrics = { [weak self] (song, placeholder) in
            self?.showLyrics(for: song, placeholder: placeholder)
        }
        scene?.flowSetup = { [weak self] mode in
            self?.showSetup(mode: mode)
        }
        router.push(scene, animated: false)
    }
    
    override var rootViewController: UIViewController {
        router
    }
    
}
