//
//  SongListAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/14/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Swinject
import UIKit

protocol SongListScene: ViewController {
    var flowLyrics: ((SharedSong, UIImage?) -> Void)? { get set }
}

enum SongListFlow: Equatable {
    case albumTracks(SpotifyAlbum)
    case trendingSongs(preview: [SharedSong])
    case viralSongs(preview: [SharedSong])
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
