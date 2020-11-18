//
//  NetworkAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Moya
import Swinject

class NetworkAssembly: Assembly {
    
    override func assemble(container: Container) {
        
        container.register(SpotifyProvider.self) { _ in
            SpotifyProvider(requestClosure: SpotifyProvider.spotifyRefreshFlowHandler())
        }
        
        container.register(GeniusProvider.self) { _ in
            GeniusProvider(requestClosure: GeniusProvider.geniusAuthMiddleware())
        }
        
    }
    
}
