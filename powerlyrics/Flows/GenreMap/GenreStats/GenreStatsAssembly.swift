//
//  GenreStatsAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/7/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import PanModal
import Swinject
import UIKit

// MARK: - GenreStatsScene

protocol GenreStatsScene: ViewController & PanModalPresentable {
    
    var flowLyrics: DefaultSharedSongPreviewAction? { get set }
    var flowDismiss: DefaultAction? { get set }
    
}

// MARK: - GenreStatsAssembly

class GenreStatsAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(GenreStatsViewModel.self) { (resolver, genre: RealmLikedSongGenre) in
            GenreStatsViewModel(
                realmService: resolver.resolve(RealmServiceProtocol.self)!,
                genre: genre
            )
        }
        
        container.register(GenreStatsScene.self) { (resolver, genre: RealmLikedSongGenre) in
            let viewController = UIStoryboard.createController(GenreStatsViewController.self)
            viewController.viewModel = resolver.resolve(GenreStatsViewModel.self, argument: genre)
            return viewController
        }
        
    }
    
}
