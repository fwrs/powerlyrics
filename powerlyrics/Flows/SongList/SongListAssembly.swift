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
    
    case findAlbumTracks(album: String, artist: String)
    case albumTracks(SpotifyAlbum)
    case trendingSongs(preview: [SharedSong])
    case viralSongs(preview: [SharedSong])
    case likedSongs
    
    var localizedTitle: String {
        
        switch self {
        case .findAlbumTracks(let album, _):
            return album.lowercased()
            
        case .albumTracks(let album):
            return album.name.lowercased()
            
        case .trendingSongs:
            return Strings.SongList.Title.trending
            
        case .viralSongs:
            return Strings.SongList.Title.viral
            
        case .likedSongs:
            return Strings.SongList.Title.likedSongs
        }
        
    }
    
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
            
            case .findAlbumTracks(let album, let artist):
                return SongListFindAlbumViewModel(
                    album: album,
                    artist: artist,
                    spotifyProvider: resolver.resolve(SpotifyProvider.self)!,
                    realmService: resolver.resolve(RealmServiceProtocol.self)!
                )
                
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
            viewController.navigationItem.title = flow.localizedTitle
            viewController.viewModel = resolver.resolve(SongListViewModel.self, argument: flow)
            return viewController
        }
        
    }
    
}
