//
//  RealmService.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 18.11.20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import RealmSwift

// MARK: - Constants

fileprivate extension Constants {
    
    static let secondToLast = 2
    
}

// MARK: - RealmServiceProtocol

fileprivate let realm = try! Realm()

protocol RealmServiceProtocol {
    func saveUserData(spotifyUserInfo: SpotifyUserInfoResponse)
    func saveUserData(name: String, over18: Bool, premium: Bool, avatar: SharedImage?, thumbnailAvatar: SharedImage?)
    func saveUserData(name: String, over18: Bool)
    func unsetUserData(reset: Bool)
    func unsetUserData()
    func findLikedSong(geniusID: Int) -> RealmLikedSong?
    func like(song: SharedSong, genre: RealmLikedSongGenre, geniusID: Int, geniusURL: String)
    func unlike(geniusID: Int)
    func likedSongs(with genre: RealmLikedSongGenre) -> [RealmLikedSong]
    func likedSongs() -> [RealmLikedSong]
    func incrementSearchesStat()
    func incrementDiscoveriesStat(with id: Int)
    func incrementViewedArtistsStat(with id: Int)
    
    var userData: RealmAccount? { get }
    var likedSongsCount: Int { get }
    var stats: RealmStats? { get }
}

// MARK: - RealmService

struct RealmService: RealmServiceProtocol {
    
    // MARK: - Authentication
    
    func saveUserData(spotifyUserInfo: SpotifyUserInfoResponse) {
        saveUserData(
            name: spotifyUserInfo.displayName ?? spotifyUserInfo.uri,
            over18: !spotifyUserInfo.explicitContent.filterEnabled,
            premium: spotifyUserInfo.product == .premium,
            avatar: spotifyUserInfo.images.first,
            thumbnailAvatar: spotifyUserInfo.images[safe: spotifyUserInfo.images.count - Constants.secondToLast] ??
                spotifyUserInfo.images.last
        )
    }
    
    func saveUserData(name: String, over18: Bool) {
        saveUserData(name: name, over18: over18, premium: false, avatar: nil, thumbnailAvatar: nil)
    }
    
    func saveUserData(
        name: String,
        over18: Bool,
        premium: Bool,
        avatar: SharedImage? = nil,
        thumbnailAvatar: SharedImage? = nil
    ) {
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
    
    var userData: RealmAccount? {
        realm.objects(RealmAccount.self).first
    }
    
    func unsetUserData() {
        unsetUserData(reset: true)
    }
    
    func unsetUserData(reset: Bool) {

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
    
    // MARK: - Likes
    
    func findLikedSong(geniusID: Int) -> RealmLikedSong? {
        realm.objects(RealmLikedSong.self).first { $0.geniusID == geniusID }
    }
    
    func like(song: SharedSong, genre: RealmLikedSongGenre, geniusID: Int, geniusURL: String) {
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
    
    func unlike(geniusID: Int) {
        guard let song = findLikedSong(geniusID: geniusID) else { return }
        
        try! realm.write {
            realm.delete(song)
        }
    }
    
    var likedSongsCount: Int {
        realm.objects(RealmLikedSong.self).count
    }
    
    func likedSongs(with genre: RealmLikedSongGenre) -> [RealmLikedSong] {
        realm.objects(RealmLikedSong.self).filter { $0.genre == genre }
    }
    
    func likedSongs() -> [RealmLikedSong] {
        Array(realm.objects(RealmLikedSong.self))
    }
    
   // MARK: - Stats
    
    var stats: RealmStats? {
        realm.objects(RealmStats.self).first
    }
    
    func incrementSearchesStat() {
        if let stat = realm.objects(RealmStats.self).first {
            try! realm.write {
                stat.searches += 1
            }
        }
    }
    
    func incrementDiscoveriesStat(with id: Int) {
        if let stat = realm.objects(RealmStats.self).first, !stat.discoveries.contains(id) {
            try! realm.write {
                stat.discoveries.append(id)
            }
        }
    }
    
    func incrementViewedArtistsStat(with id: Int) {
        if let stat = realm.objects(RealmStats.self).first, !stat.viewedArtists.contains(id) {
            try! realm.write {
                stat.viewedArtists.append(id)
            }
        }
    }
    
}
