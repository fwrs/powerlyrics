//
//  Keychain.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Foundation
import KeychainAccess

protocol KeychainStorageProtocol: class {
    
    func setEncodable<T: Encodable>(_ value: T?, for key: KeychainStorage.Key)
    func getDecodable<T: Decodable>(for key: KeychainStorage.Key) -> T?
    func getString(for key: KeychainStorage.Key) -> String?
    func setString(_ value: String?, for key: KeychainStorage.Key)
    func delete(for key: KeychainStorage.Key)
    func reset()
    
}

final class KeychainStorage: KeychainStorageProtocol {

    var decoder: JSONDecoder!
    
    var encoder: JSONEncoder!
    
    private static let keychain: Keychain = {
        guard let service = Bundle.main.infoDictionary?[String(kCFBundleIdentifierKey)]  as? String else {
            fatalError()
        }
        
        return Keychain(service: service)
            .accessibility(.whenUnlockedThisDeviceOnly)
    }()
    
    private var keychain: Keychain {
        KeychainStorage.keychain
    }
    
    enum Key: String {
        case user
        case profile
        case passcode
        
        static let all: [Key] = [.user, .passcode, .profile]
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
        } catch let error {
            print(error)
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
        Key.all.forEach { key in
            self.delete(for: key)
        }
    }
    
}
