//
//  SearchAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Swinject
import UIKit

protocol SearchScene: ViewController {
    var flowLyrics: ((SharedSong, UIImage?) -> Void)? { get set }
    var flowAlbum: ((SpotifyAlbum) -> Void)? { get set }
}

class SearchAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(SearchViewModel.self) { resolver in
            SearchViewModel(
                spotifyProvider: resolver.resolve(SpotifyProvider.self)!,
                geniusProvider: resolver.resolve(GeniusProvider.self)!
            )
        }
        
        container.register(SearchScene.self) { resolver in
            let viewController = UIStoryboard.createController(SearchViewController.self)
            viewController.viewModel = resolver.resolve(SearchViewModel.self)
            return viewController
        }
        
    }
    
}
