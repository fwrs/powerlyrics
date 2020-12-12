//
//  GenreMapStatsAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/7/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import PanModal
import Swinject

// MARK: - GenreMapStatsScene

protocol GenreMapStatsScene: ViewController & PanModalPresentable {
    
    var flowLyrics: DefaultSharedSongPreviewAction? { get set }
    var flowDismiss: DefaultAction? { get set }
    
}

// MARK: - GenreMapStatsAssembly

class GenreMapStatsAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(GenreMapStatsViewModel.self) { (resolver, genre: RealmLikedSongGenre) in
            GenreMapStatsViewModel(
                realmService: resolver.resolve(RealmServiceProtocol.self)!,
                genre: genre
            )
        }
        
        container.register(GenreMapStatsScene.self) { (resolver, genre: RealmLikedSongGenre) in
            let viewController = UIStoryboard.createController(GenreMapStatsViewController.self)
            viewController.viewModel = resolver.resolve(GenreMapStatsViewModel.self, argument: genre)
            return viewController
        }
        
    }
    
}
