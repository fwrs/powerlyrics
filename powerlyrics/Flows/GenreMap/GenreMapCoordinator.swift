//
//  GenreMapCoordinator.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//

import PanModal
import Swinject
import UIKit

class GenreMapCoordinator: Coordinator {
    
    let router: Router

    init(router: Router, resolver: Resolver) {
        self.router = router
        super.init(resolver: resolver)
    }
    
    override func start() {
        let scene = resolver.resolve(GenreMapScene.self)
        scene?.flowGenre = { [weak self] genre in
            self?.showGenre(genre)
        }
        router.push(scene, animated: false)
    }
    
    func showGenre(_ genre: LikedSongGenre) {
        let scene = resolver.resolve(GenreStatsScene.self)!
        let genreRouter = Router(rootViewController: scene)
        if let tabBarController = router.tabBarController {
            let blurView = UIVisualEffectView(effect: nil)
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut) {
                blurView.effect = UIBlurEffect(style: .systemThinMaterial)
            }
            tabBarController.view.addSubview(blurView)
            blurView.isUserInteractionEnabled = false
            blurView.frame = UIScreen.main.bounds
            tabBarController.view.bringSubviewToFront(blurView)
            scene.flowDismiss = {
                UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut) {
                    blurView.effect = nil
                } completion: { _ in
                    blurView.removeFromSuperview()
                }
            }
        }
        scene.flowLyrics = { [weak self] (song, placeholder) in
            self?.showLyrics(for: song, placeholder: placeholder, from: genreRouter)
        }
        router.presentPanModal(genreRouter)
    }
    
    private var genreViewControllerRouter: UIViewController?
    
    func showLyrics(for song: SharedSong, placeholder: UIImage?, from sourceViewController: UIViewController) {
        let lyricsCoordinator = resolver.resolve(LyricsCoordinator.self, arguments: Router(), sourceViewController, { [self] in
            childCoordinators.removeAll { $0.isKind(of: LyricsCoordinator.self) }
        }, song, placeholder)!
        childCoordinators.append(lyricsCoordinator)
        lyricsCoordinator.start()
    }
    
    override var rootViewController: UIViewController {
        router
    }
    
}
