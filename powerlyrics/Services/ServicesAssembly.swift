//
//  ServicesAssembly.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Swinject

// MARK: - Constants

fileprivate extension Constants {
    
    static let defaultDateFormat = "yyyy-MM-dd HH:mm:ss"
    
    static let defaultLocale = "en_US_POSIX"
    
}

// MARK: - ServicesAssembly

class ServicesAssembly: Assembly {
    
    override func assemble(container: Container) {
        
        container.register(JSONEncoder.self) { _ in
            let df = DateFormatter()
            df.calendar = Calendar(identifier: .iso8601)
            df.dateFormat = Constants.defaultDateFormat
            df.locale = Locale(identifier: Constants.defaultLocale)
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(df)
            return encoder
        }
        
        container.register(JSONDecoder.self) { _ in
            let df = DateFormatter()
            df.calendar = Calendar(identifier: .iso8601)
            df.dateFormat = Constants.defaultDateFormat
            df.locale = Locale(identifier: Constants.defaultLocale)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(df)
            return decoder
        }
    
        container.register(KeychainServiceProtocol.self) { resolver in
            let keychain = KeychainService()
            keychain.decoder = resolver.resolve(JSONDecoder.self)
            keychain.encoder = resolver.resolve(JSONEncoder.self)
            return keychain
        }
        
        container.register(RealmServiceProtocol.self) { _ in
            RealmService()
        }
        
    }
    
}
