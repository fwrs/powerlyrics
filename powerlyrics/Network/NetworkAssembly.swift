//
//  NetworkAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Swinject

class Spot: Assembly {
    
    override func assemble(container: Container) {
        
        container.register(SpotifyProvider.self) { _ in
            SpotifyProvider()
        }
        
    }
    
}
