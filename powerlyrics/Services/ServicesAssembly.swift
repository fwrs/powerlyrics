//
//  ServicesAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Foundation
import Swinject

class ServicesAssembly: Assembly {
    
    override func assemble(container: Container) {
        
        container.register(JSONEncoder.self) { _ in
            let df = DateFormatter()
            df.calendar = Calendar(identifier: .iso8601)
            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
            df.locale = Locale(identifier: "en_US_POSIX")
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(df)
            return encoder
        }
        
        container.register(JSONDecoder.self) { _ in
            let df = DateFormatter()
            df.calendar = Calendar(identifier: .iso8601)
            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
            df.locale = Locale(identifier: "en_US_POSIX")
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(df)
            return decoder
        }
    
        container.register(KeychainStorageProtocol.self) { resolver in
            let keychain = KeychainStorage()
            keychain.decoder = resolver.resolve(JSONDecoder.self)
            keychain.encoder = resolver.resolve(JSONEncoder.self)
            return keychain
        }
        
    }
    
}
