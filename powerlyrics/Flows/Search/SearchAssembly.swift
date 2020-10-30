//
//  SearchAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//

import Swinject
import UIKit

protocol SearchScene: ViewController {
    var flowLyrics: ((Shared.Song, UIImage?) -> Void)? { get set }
}

class SearchAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(SearchViewModel.self) { resolver in
            SearchViewModel(geniusProvider: resolver.resolve(GeniusProvider.self)!)
        }
        
        container.register(SearchScene.self) { resolver in
            let viewController = UIStoryboard.createController(SearchViewController.self)
            viewController.viewModel = resolver.resolve(SearchViewModel.self)
            return viewController
        }
        
    }
    
}
