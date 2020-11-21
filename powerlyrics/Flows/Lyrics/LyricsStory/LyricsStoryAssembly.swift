//
//  LyricsStoryAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/21/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import PanModal
import Swinject

// MARK: - LyricsStoryScene

protocol LyricsStoryScene: ViewController & PanModalPresentable {

    var flowDismiss: DefaultAction? { get set }
    
}

// MARK: - LyricsStoryAssembly

class LyricsStoryAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(LyricsStoryViewModel.self) { (_, story: String) in
            LyricsStoryViewModel(story: story)
        }
        
        container.register(LyricsStoryScene.self) { (resolver, story: String) in
            let viewController = UIStoryboard.createController(LyricsStoryViewController.self)
            viewController.viewModel = resolver.resolve(LyricsStoryViewModel.self, argument: story)
            return viewController
        }
        
    }
    
}
