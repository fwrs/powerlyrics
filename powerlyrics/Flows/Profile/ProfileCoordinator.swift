//
//  ProfileCoordinator.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import SafariServices
import Swinject

class ProfileCoordinator: Coordinator {
    
    // MARK: - Instance properties
    
    let router: Router
    
    // MARK: - Init

    init(router: Router, resolver: Resolver) {
        self.router = router
        super.init(resolver: resolver)
    }
    
    // MARK: - Coordinator
    
    override func start() {
        let scene = resolver.resolve(ProfileScene.self)
        scene?.flowSafari = { [weak self] url in
            self?.showSafari(url: url)
        }
        scene?.flowLikedSongs = { [weak self] in
            self?.showLikedSongs()
        }
        scene?.flowSetup = { [weak self] mode in
            self?.showSetup(mode: mode)
        }
        router.push(scene, animated: false)
    }
    
    // MARK: - Scenes
    
    func showLikedSongs() {
        let scene = resolver.resolve(SongListScene.self, argument: SongListFlow.likedSongs)
        scene?.flowLyrics = { [weak self] (song, placeholder) in
            self?.showLyrics(for: song, placeholder: placeholder)
        }
        router.push(scene)
    }
    
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
    
    func showSafari(url: URL) {
        let safariViewController = SFSafariViewController(
            url: url,
            configuration: SFSafariViewController.Configuration()
        )
        safariViewController.preferredControlTintColor = .tintColor
        router.present(safariViewController, animated: true)
    }
    
}
