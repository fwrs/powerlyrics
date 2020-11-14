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
        scene?.flowLikedSongs = { [weak self] in
            self?.showLikedSongs()
        }
        router.push(scene, animated: false)
    }
    
    override var rootViewController: UIViewController {
        router
    }
    
    func showLikedSongs() {
        let scene = resolver.resolve(SongListScene.self, argument: SongListFlow.likedSongs)
        scene?.flowLyrics = { [weak self] (song, placeholder) in
            self?.showLyrics(for: song, placeholder: placeholder)
        }
        router.push(scene)
    }
    
    func showLyrics(for song: SharedSong, placeholder: UIImage?) {
        let lyricsCoordinator = resolver.resolve(LyricsCoordinator.self, arguments: Router(), rootViewController, { [self] in
            childCoordinators.removeAll { $0.isKind(of: LyricsCoordinator.self) }
        }, song, placeholder)!
        childCoordinators.append(lyricsCoordinator)
        lyricsCoordinator.start()
    }
    
}
