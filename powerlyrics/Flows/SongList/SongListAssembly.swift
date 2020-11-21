//
//  SongListAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/14/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Swinject

// MARK: - SongListFlow

enum SongListFlow: Equatable {
    
    case albumTracks(SpotifyAlbum)
    case trendingSongs(preview: [SharedSong])
    case viralSongs(preview: [SharedSong])
    case likedSongs
    
}

// MARK: - SongListScene

protocol SongListScene: ViewController {
    
    var flowLyrics: DefaultSharedSongPreviewAction? { get set }
    
}

// MARK: - SongListAssembly

class SongListAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(SongListViewModel.self) { (resolver, flow: SongListFlow) in
            switch flow {
            
            case .albumTracks(let album):
                return SongListAlbumViewModel(
                    album: album,
                    spotifyProvider: resolver.resolve(SpotifyProvider.self)!,
                    realmService: resolver.resolve(RealmServiceProtocol.self)!
                )
            case .trendingSongs(let preview):
                return SongListTrendingViewModel(
                    preview: preview,
                    spotifyProvider: resolver.resolve(SpotifyProvider.self)!,
                    realmService: resolver.resolve(RealmServiceProtocol.self)!
                )
            case .viralSongs(let preview):
                return SongListViralViewModel(
                    preview: preview,
                    spotifyProvider: resolver.resolve(SpotifyProvider.self)!,
                    realmService: resolver.resolve(RealmServiceProtocol.self)!
                )
            case .likedSongs:
                return SongListLikedViewModel(
                    spotifyProvider: resolver.resolve(SpotifyProvider.self)!,
                    realmService: resolver.resolve(RealmServiceProtocol.self)!
                )
            }
        }
        
        container.register(SongListScene.self) { (resolver, flow: SongListFlow) in
            let viewController = UIStoryboard.createController(SongListViewController.self)
            viewController.viewModel = resolver.resolve(SongListViewModel.self, argument: flow)
            return viewController
        }
        
    }
    
}
