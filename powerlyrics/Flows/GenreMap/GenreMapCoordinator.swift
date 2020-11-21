//
//  GenreMapCoordinator.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import PanModal
import Swinject

// MARK: - Constants

extension Constants {
    
    static let globalBlurStyle = UIBlurEffect.Style.systemUltraThinMaterial
    
}

// MARK: - GenreMapCoordinator

class GenreMapCoordinator: Coordinator {
    
    // MARK: - Instance properties
    
    let router: Router
    
    var genreViewControllerRouter: UIViewController?
    
    // MARK: - Init

    init(router: Router, resolver: Resolver) {
        self.router = router
        super.init(resolver: resolver)
    }
    
    // MARK: - Coordinator
    
    override func start() {
        let scene = resolver.resolve(GenreMapScene.self)
        scene?.flowGenre = { [weak self] genre in
            self?.showGenre(genre)
        }
        scene?.flowLikedSongs = { [weak self] in
            self?.showLikedSongs()
        }
        router.push(scene, animated: false)
    }
    
    // MARK: - Scenes
    
    func showGenre(_ genre: RealmLikedSongGenre) {
        let scene = resolver.resolve(GenreStatsScene.self, argument: genre)!
        if let tabBarController = router.tabBarController {
            let blurView = UIVisualEffectView(effect: nil)
            
            UIView.animate(withDuration: Constants.defaultAnimationDuration, options: .curveEaseOut) {
                blurView.effect = UIBlurEffect(style: Constants.globalBlurStyle)
            }
            
            tabBarController.view.addSubview(blurView)
            blurView.isUserInteractionEnabled = false
            blurView.frame = UIScreen.main.bounds
            tabBarController.view.bringSubviewToFront(blurView)
            
            scene.flowDismiss = {
                UIView.animate(withDuration: Constants.defaultAnimationDuration, options: .curveEaseOut) {
                    blurView.effect = nil
                } completion: { _ in
                    blurView.removeFromSuperview()
                }
            }
        }
        
        scene.flowLyrics = { [weak self] (song, placeholder) in
            self?.showLyrics(for: song, placeholder: placeholder, from: scene)
        }
        
        router.presentPanModal(scene)
    }
    
    func showLyrics(for song: SharedSong, placeholder: UIImage?, from viewController: UIViewController) {
        let lyricsCoordinator = resolver.resolve(
            LyricsCoordinator.self,
            arguments: viewController, self as PresenterCoordinator, song, placeholder
        )!
        childCoordinators.append(lyricsCoordinator)
        lyricsCoordinator.start()
    }
    
    func showLikedSongs() {
        let scene = resolver.resolve(SongListScene.self, argument: SongListFlow.likedSongs)
        scene?.flowLyrics = { [weak self] (song, placeholder) in
            guard let self = self else {
                return
            }
            self.showLyrics(for: song, placeholder: placeholder, from: self.router)
        }
        router.push(scene)
    }
    
}
