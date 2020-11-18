//
//  GenreMapAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Swinject
import UIKit

protocol GenreMapScene: ViewController {
    var flowGenre: DefaultRealmLikedSongGenreAction? { get set }
    var flowLikedSongs: DefaultAction? { get set }
}

class GenreMapAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(GenreMapViewModel.self) { _ in
            GenreMapViewModel()
        }
        
        container.register(GenreMapScene.self) { resolver in
            let viewController = UIStoryboard.createController(GenreMapViewController.self)
            viewController.viewModel = resolver.resolve(GenreMapViewModel.self)
            return viewController
        }
        
    }
    
}
