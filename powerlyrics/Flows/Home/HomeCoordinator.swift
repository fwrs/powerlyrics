//
//  HomeCoordinator.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import SafariServices
import Swinject

class HomeCoordinator: Coordinator {
    
    // MARK: - Instance properties
    
    let router: Router
    
    // MARK: - Init

    init(router: Router, resolver: Resolver) {
        self.router = router
        super.init(resolver: resolver)
    }
    
    // MARK: - Coordinator
    
    override func start() {
        let scene = resolver.resolve(HomeScene.self)
        scene?.flowSafari = { [weak self] url in
            self?.showSafari(url: url)
        }
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
    
    // MARK: - Scenes
    
    func showLyrics(for song: SharedSong, placeholder: UIImage?) {
        let lyricsCoordinator = resolver.resolve(
            LyricsCoordinator.self,
            arguments: router, self as PresenterCoordinator, song, placeholder
        )!
        childCoordinators.append(lyricsCoordinator)
        lyricsCoordinator.start()
    }
    
    func showSetup(mode: SetupMode) {
        let setupCoordinator = resolver.resolve(
            SetupCoordinator.self,
            arguments: router, self as PresenterCoordinator, mode
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
    
    func showSafari(url: URL) {
        let safariViewController = SFSafariViewController(
            url: url,
            configuration: SFSafariViewController.Configuration()
        )
        safariViewController.preferredControlTintColor = .tintColor
        router.present(safariViewController, animated: true)
    }
    
}
