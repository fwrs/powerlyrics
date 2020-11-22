//
//  LyricsAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/3/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Swinject

// MARK: - LyricsScene

protocol LyricsScene: ViewController {
    
    var isMainScene: Bool { get set }
    
    var flowSafari: DefaultURLAction? { get set }
    var flowStory: DefaultStringAction? { get set }
    var flowFindAlbum: DefaultAlbumStringsAction? { get set }
    var flowDismiss: DefaultAction? { get set }
    
}

typealias DefaultAlbumStringsAction = (_ album: String, _ artist: String) -> Void

// MARK: - LyricsAssembly

class LyricsAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(LyricsViewModel.self) { (resolver, song: SharedSong) in
            LyricsViewModel(
                geniusProvider: resolver.resolve(GeniusProvider.self)!,
                realmService: resolver.resolve(RealmServiceProtocol.self)!,
                song: song
            )
        }
        
        container.register(LyricsScene.self) { (resolver, song: SharedSong, albumArtThumbnail: UIImage?) in
            let viewController = UIStoryboard.createController(LyricsViewController.self)
            viewController.viewModel = resolver.resolve(LyricsViewModel.self, argument: song)
            viewController.albumArtThumbnail = albumArtThumbnail
            return viewController
        }
        
    }
    
}
