//
//  KeychainService.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import KeychainAccess

// MARK: - KeychainServiceProtocol

protocol KeychainServiceProtocol: class {
    func setEncodable<T: Encodable>(_ value: T?, for key: KeychainService.Key)
    func getDecodable<T: Decodable>(for key: KeychainService.Key) -> T?
    func getString(for key: KeychainService.Key) -> String?
    func setString(_ value: String?, for key: KeychainService.Key)
    func delete(for key: KeychainService.Key)
    func reset()
}

// MARK: - KeychainService

class KeychainService: KeychainServiceProtocol {

    var decoder: JSONDecoder!
    
    var encoder: JSONEncoder!
    
    private static let keychain: Keychain = {
        guard let service = Bundle.main.infoDictionary?[String(kCFBundleIdentifierKey)]  as? String else {
            fatalError()
        }
        
        return Keychain(service: service)
            .accessibility(.always)
    }()
    
    var keychain: Keychain {
        KeychainService.keychain
    }
    
    enum Key: String {
        case spotifyToken
        case spotifyAuthorizedWithAccount
        
        static let all: [Key] = [.spotifyToken, .spotifyAuthorizedWithAccount]
    }
    
    func setEncodable<T: Encodable>(_ value: T?, for key: Key) {
        guard let value = value else {
            delete(for: key)
            return
        }
        do {
            let data = try encoder.encode(value)
            try keychain.set(data, key: key.rawValue)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func getDecodable<T: Decodable>(for key: Key) -> T? {
        do {
            guard let data = try keychain.getData(key.rawValue) else { return nil }
            return try decoder.decode(T.self, from: data)
        } catch {
            return nil
        }
    }
    
    func getString(for key: Key) -> String? {
        do {
            return try keychain.getString(key.rawValue)
        } catch {
            return nil
        }
    }

    func setString(_ value: String?, for key: Key) {
        guard let value = value else {
            delete(for: key)
            return
        }
        do {
            try keychain.set(value, key: key.rawValue)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func delete(for key: Key) {
        do {
            try keychain.remove(key.rawValue)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func reset() {
        Key.all.forEach { [weak self] key in
            self?.delete(for: key)
        }
    }
    
}
