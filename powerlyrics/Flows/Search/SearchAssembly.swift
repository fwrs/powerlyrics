//
//  SearchAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Swinject
import UIKit

// MARK: - SearchScene

protocol SearchScene: ViewController {
    
    var flowLyrics: DefaultSharedSongPreviewAction? { get set }
    var flowAlbum: DefaultSpotifyAlbumAction? { get set }
    
}

// MARK: - SearchAssembly

class SearchAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(SearchViewModel.self) { resolver in
            SearchViewModel(
                spotifyProvider: resolver.resolve(SpotifyProvider.self)!,
                geniusProvider: resolver.resolve(GeniusProvider.self)!,
                realmService: resolver.resolve(RealmServiceProtocol.self)!
            )
        }
        
        container.register(SearchScene.self) { resolver in
            let viewController = UIStoryboard.createController(SearchViewController.self)
            viewController.viewModel = resolver.resolve(SearchViewModel.self)
            return viewController
        }
        
    }
    
}
