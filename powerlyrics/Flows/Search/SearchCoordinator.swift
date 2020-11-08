//
//  SearchCoordinator.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//

import Swinject
import UIKit

class SearchCoordinator: Coordinator {
    
    let router: Router

    init(router: Router, resolver: Resolver) {
        self.router = router
        super.init(resolver: resolver)
    }
    
    override func start() {
        let scene = resolver.resolve(SearchScene.self)
        scene?.flowLyrics = { [weak self] (song, placeholder) in
            self?.showLyrics(for: song, placeholder: placeholder)
        }
        router.push(scene, animated: false)
    }
    
    func showLyrics(for song: SharedSong, placeholder: UIImage?) {
        let lyricsCoordinator = resolver.resolve(LyricsCoordinator.self, arguments: Router(), rootViewController, { [self] in
            childCoordinators.removeAll { $0.isKind(of: LyricsCoordinator.self) }
        }, song, placeholder)!
        childCoordinators.append(lyricsCoordinator)
        lyricsCoordinator.start()
    }

    override var rootViewController: UIViewController {
        router
    }
    
}
