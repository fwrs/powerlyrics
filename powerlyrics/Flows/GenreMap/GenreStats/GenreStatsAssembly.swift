//
//  GenreStatsAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/7/20.
//

import PanModal
import Swinject
import UIKit

protocol GenreStatsScene: ViewController & PanModalPresentable {
    var flowLyrics: ((SharedSong, UIImage?) -> Void)? { get set }
    var flowDismiss: DefaultAction? { get set }
}

class GenreStatsAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(GenreStatsViewModel.self) { (_, genre: RealmLikedSongGenre) in
            GenreStatsViewModel(genre: genre)
        }
        
        container.register(GenreStatsScene.self) { (resolver, genre: RealmLikedSongGenre) in
            let viewController = UIStoryboard.createController(GenreStatsViewController.self)
            viewController.viewModel = resolver.resolve(GenreStatsViewModel.self, argument: genre)
            return viewController
        }
        
    }
    
}
