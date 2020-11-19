//
//  SetupAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 19.11.20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Swinject

// MARK: - SetupAssembly

class SetupAssembly: Assembly {

    override func assemble(container: Container) {
        
        container.register(SetupSharedSpotifyViewModel.self) { resolver in
            SetupSharedSpotifyViewModel(
                spotifyProvider: resolver.resolve(SpotifyProvider.self)!,
                realmService: resolver.resolve(RealmServiceProtocol.self)!,
                keychainService: resolver.resolve(KeychainServiceProtocol.self)!
            )
        }.inObjectScope(.weak)
        
    }
    
}
