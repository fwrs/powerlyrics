//
//  LyricsAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/3/20.
//

import Swinject
import UIKit

class LyricsAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(LyricsViewModel.self) { (_, song: Song) in
            LyricsViewModel(song: song)
        }
        
        container.register(LyricsScene.self) { (resolver, song: Song) in
            let viewController = UIStoryboard.createController(LyricsViewController.self)
            viewController.viewModel = resolver.resolve(LyricsViewModel.self, argument: song)
            return viewController
        }
        
    }
    
}
