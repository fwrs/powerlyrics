//
//  SearchCoordinator.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Swinject

class SearchCoordinator: Coordinator {
    
    // MARK: - Instance properties

    let router: Router
    
    // MARK: - Init

    init(router: Router, resolver: Resolver) {
        self.router = router
        super.init(resolver: resolver)
    }
    
    // MARK: - Coordinator
    
    override func start() {
        let scene = resolver.resolve(SearchScene.self)
        scene?.flowLyrics = { [weak self] song, placeholder in
            self?.showLyrics(for: song, placeholder: placeholder)
        }
        scene?.flowAlbum = { [weak self] album in
            self?.showAlbum(album)
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

    func showAlbum(_ album: SpotifyAlbum) {
        let scene = resolver.resolve(SongListScene.self, argument: SongListFlow.albumTracks(album))
        scene?.flowLyrics = { [weak self] (song, placeholder) in
            self?.showLyrics(for: song, placeholder: placeholder)
        }
        router.push(scene)
    }
    
}
