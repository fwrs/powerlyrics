//
//  CoordinatorsAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Swinject

class CoordinatorsAssembly: Assembly {
    
    override func assemble(container: Container) {
        
        // MARK: - Tab Bar
        
        container.register(TabBarCoordinator.self) { resolver in
            TabBarCoordinator(window: resolver.resolve(UIWindow.self)!, resolver: resolver)
        }.inObjectScope(.transient)
        
        // MARK: - Tab Bar items
        
        container.register(HomeCoordinator.self) { (resolver, router: Router) in
            HomeCoordinator(router: router, resolver: resolver)
        }
        
        container.register(SearchCoordinator.self) { (resolver, router: Router) in
            SearchCoordinator(router: router, resolver: resolver)
        }
        
        container.register(GenreMapCoordinator.self) { (resolver, router: Router) in
            GenreMapCoordinator(router: router, resolver: resolver)
        }
        
        container.register(ProfileCoordinator.self) { (resolver, router: Router) in
            ProfileCoordinator(router: router, resolver: resolver)
        }
        
        // MARK: - Supplementary screens
        
        container.register(LyricsCoordinator.self) { (resolver, source: UIViewController, presenter: PresenterCoordinator, song: SharedSong, placeholder: UIImage?) in
            LyricsCoordinator(
                source: source,
                resolver: resolver,
                presenter: presenter,
                song: song,
                placeholder: placeholder
            )
        }
        
        container.register(SetupCoordinator.self) { (resolver, source: UIViewController, presenter: PresenterCoordinator, mode: SetupMode) in
            SetupCoordinator(
                source: source,
                resolver: resolver,
                presenter: presenter,
                spotifyProvider: resolver.resolve(SpotifyProvider.self)!,
                mode: mode
            )
        }
        
        container.register(LyricsCoordinator.self) { (resolver, source: Router, presenter: PresenterCoordinator, song: SharedSong, placeholder: UIImage?) in
            LyricsCoordinator(
                source: source,
                resolver: resolver,
                presenter: presenter,
                song: song,
                placeholder: placeholder
            )
        }
        
        container.register(SetupCoordinator.self) { (resolver, source: Router, presenter: PresenterCoordinator, mode: SetupMode) in
            SetupCoordinator(
                source: source,
                resolver: resolver,
                presenter: presenter,
                spotifyProvider: resolver.resolve(SpotifyProvider.self)!,
                mode: mode
            )
        }
        
    }
    
}
