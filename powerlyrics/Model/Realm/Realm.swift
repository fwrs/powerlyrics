//
//  Realm.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/6/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Foundation
import RealmSwift

fileprivate let realm = try! Realm()

extension Realm {
    
    static func saveUserData(spotifyUserInfo: SpotifyUserInfoResponse) {
        saveUserData(
            name: spotifyUserInfo.displayName ?? spotifyUserInfo.uri,
            over18: !spotifyUserInfo.explicitContent.filterEnabled,
            premium: spotifyUserInfo.product == .premium,
            avatar: spotifyUserInfo.images.first,
            thumbnailAvatar: spotifyUserInfo.images[safe: spotifyUserInfo.images.count - 2] ?? spotifyUserInfo.images.last
        )
    }
    
    static func saveUserData(name: String, over18: Bool, premium: Bool = false, avatar: SharedImage? = nil, thumbnailAvatar: SharedImage? = nil) {
        
        let account = RealmAccount()
        account.name = name
        account.over18 = over18
        account.premium = premium
        account.registerDate = Date()
        if case .external(let url) = avatar {
            account.avatarURL = url.absoluteString
        }
        if case .external(let url) = thumbnailAvatar {
            account.thumbnailAvatarURL = url.absoluteString
        }
        
        let stats = RealmStats()
        
        try! realm.write {
            realm.add(account)
            realm.add(stats)
        }
        
    }
    
    static var userData: RealmAccount? {
        realm.objects(RealmAccount.self).first
    }
    
    static func unsetUserData(reset: Bool = true) {

        if reset {
            try! realm.write {
                realm.deleteAll()
            }
        } else {
            try! realm.write {
                realm.delete(realm.objects(RealmAccount.self))
            }
        }
        
    }
    
    static func findLikedSong(geniusID: Int) -> RealmLikedSong? {
        realm.objects(RealmLikedSong.self).first { $0.geniusID == geniusID }
    }
    
    static func like(song: SharedSong, genre: RealmLikedSongGenre, geniusID: Int, geniusURL: String) {
        if findLikedSong(geniusID: geniusID) != nil { return }
        
        let likedSong = RealmLikedSong()
        likedSong.name = song.name
        likedSong.artists.append(objectsIn: song.artists)
        likedSong.genre = genre
        likedSong.likeDate = Date()
        
        if case .external(let url) = song.albumArt {
            likedSong.albumArtURL = url.absoluteString
        }
        if case .external(let url) = song.thumbnailAlbumArt {
            likedSong.thumbnailAlbumArtURL = url.absoluteString
        }
        likedSong.geniusID = geniusID
        likedSong.geniusURL = geniusURL
        
        try! realm.write {
            realm.add(likedSong)
        }
    }
    
    static func unlike(geniusID: Int) {
        guard let song = findLikedSong(geniusID: geniusID) else { return }
        
        try! realm.write {
            realm.delete(song)
        }
    }
    
    static var likedSongsCount: Int {
        realm.objects(RealmLikedSong.self).count
    }
    
    static func likedSongs(with genre: RealmLikedSongGenre) -> [RealmLikedSong] {
        realm.objects(RealmLikedSong.self).filter { $0.genre == genre }
    }
    
    static func likedSongs() -> [RealmLikedSong] {
        Array(realm.objects(RealmLikedSong.self))
    }
    
    static var stats: RealmStats? {
        realm.objects(RealmStats.self).first
    }
    
    static func incrementSearchesStat() {
        if let stat = realm.objects(RealmStats.self).first {
            try! realm.write {
                stat.searches += 1
            }
        }
    }
    
    static func incrementDiscoveriesStat(with id: Int) {
        if let stat = realm.objects(RealmStats.self).first, !stat.discoveries.contains(id) {
            try! realm.write {
                stat.discoveries.append(id)
            }
        }
    }
    
    static func incrementViewedArtistsStat(with id: Int) {
        if let stat = realm.objects(RealmStats.self).first, !stat.viewedArtists.contains(id) {
            try! realm.write {
                stat.viewedArtists.append(id)
            }
        }
    }
    
}
