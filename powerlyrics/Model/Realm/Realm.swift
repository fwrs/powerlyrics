//
//  Realm.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/6/20.
//

import Foundation
import RealmSwift

fileprivate let realm = try! Realm()

extension Realm {
    
    static func saveUserData(spotifyUserInfo: SpotifyUserInfoResponse) {
        saveUserData(
            name: spotifyUserInfo.displayName ?? spotifyUserInfo.uri,
            over18: !spotifyUserInfo.explicitContent.filterEnabled,
            premium: spotifyUserInfo.product == .premium
        )
    }
    
    static func saveUserData(name: String, over18: Bool, premium: Bool = false) {
        
        unsetUserData()
        
        let account = RealmAccount()
        account.name = name
        account.over18 = over18
        account.premium = premium
        account.registerDate = Date()
        
        try! realm.write {
            realm.add(account)
        }
        
    }
    
    static var userData: RealmAccount? {
        realm.objects(RealmAccount.self).first
    }
    
    static func unsetUserData() {

        try! realm.write {
            realm.deleteAll()
        }
        
    }
    
}
