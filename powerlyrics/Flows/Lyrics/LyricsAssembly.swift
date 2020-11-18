//
//  LyricsAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/3/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Swinject
import UIKit

protocol LyricsScene: ViewController {
    var flowDismiss: DefaultAction? { get set }
}

class LyricsAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(LyricsViewModel.self) { (resolver, song: SharedSong) in
            LyricsViewModel(geniusProvider: resolver.resolve(GeniusProvider.self)!, song: song)
        }
        
        container.register(LyricsScene.self) { (resolver, song: SharedSong, albumArtThumbnail: UIImage?) in
            let viewController = UIStoryboard.createController(LyricsViewController.self)
            viewController.viewModel = resolver.resolve(LyricsViewModel.self, argument: song)
            viewController.albumArtThumbnail = albumArtThumbnail
            return viewController
        }
        
    }
    
}
