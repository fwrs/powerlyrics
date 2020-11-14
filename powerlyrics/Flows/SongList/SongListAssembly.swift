//
//  SongListAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 14.11.20.
//

import Swinject
import UIKit

protocol SongListScene: ViewController {
    var flowLyrics: ((SharedSong, UIImage?) -> Void)? { get set }
}

enum SongListFlow {
    case albumTracks(SpotifyAlbum)
    case trendingSongs
    case viralSongs
    case likedSongs
}

class SongListAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(SongListViewModel.self) { (resolver, flow: SongListFlow) in
            SongListViewModel(
                flow: flow,
                spotifyProvider: resolver.resolve(SpotifyProvider.self)!
            )
        }
        
        container.register(SongListScene.self) { (resolver, flow: SongListFlow) in
            let viewController = UIStoryboard.createController(SongListViewController.self)
            viewController.viewModel = resolver.resolve(SongListViewModel.self, argument: flow)
            return viewController
        }
        
    }
    
}
