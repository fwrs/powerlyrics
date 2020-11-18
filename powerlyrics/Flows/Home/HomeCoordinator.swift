//
//  HomeCoordinator.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Swinject
import UIKit

class HomeCoordinator: Coordinator {
    
    // MARK: - Instance properties
    
    let router: Router
    
    // MARK: - Init

    init(router: Router, resolver: Resolver) {
        self.router = router
        super.init(resolver: resolver)
    }
    
    // MARK: - Scenes
    
    func showLyrics(for song: SharedSong, placeholder: UIImage?) {
        let lyricsCoordinator = resolver.resolve(
            LyricsCoordinator.self,
            arguments:
                Router(),
                rootViewController,
                { [self] in childCoordinators.removeAll { $0.isKind(of: LyricsCoordinator.self) } },
                song,
                placeholder
        )!
        childCoordinators.append(lyricsCoordinator)
        lyricsCoordinator.start()
    }
    
    func showSetup(mode: SetupMode) {
        let setupCoordinator = resolver.resolve(
            SetupCoordinator.self,
            arguments:
                Router(),
                rootViewController,
                { [self] in childCoordinators.removeAll { $0.isKind(of: SetupCoordinator.self) } },
                mode
        )!
        childCoordinators.append(setupCoordinator)
        setupCoordinator.start()
    }
    
    func showTrends(preview: [SharedSong]) {
        let scene = resolver.resolve(SongListScene.self, argument: SongListFlow.trendingSongs(preview: preview))
        scene?.flowLyrics = { [weak self] (song, placeholder) in
            self?.showLyrics(for: song, placeholder: placeholder)
        }
        router.push(scene)
    }
    
    func showVirals(preview: [SharedSong]) {
        let scene = resolver.resolve(SongListScene.self, argument: SongListFlow.viralSongs(preview: preview))
        scene?.flowLyrics = { [weak self] (song, placeholder) in
            self?.showLyrics(for: song, placeholder: placeholder)
        }
        router.push(scene)
    }
    
    // MARK: - Coordinator
    
    override func start() {
        let scene = resolver.resolve(HomeScene.self)
        scene?.flowLyrics = { [weak self] (song, placeholder) in
            self?.showLyrics(for: song, placeholder: placeholder)
        }
        scene?.flowSetup = { [weak self] mode in
            self?.showSetup(mode: mode)
        }
        scene?.flowTrends = { [weak self] preview in
            self?.showTrends(preview: preview)
        }
        scene?.flowVirals = { [weak self] preview in
            self?.showVirals(preview: preview)
        }
        router.push(scene, animated: false)
    }
    
    override var rootViewController: UIViewController {
        router
    }
    
}
