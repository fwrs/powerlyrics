//
//  SpotifyResponses.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/23/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

struct SpotifyPlayingContextResponse: Codable {
    
    let timestamp: Int
    let item: SpotifySong
    
}

struct SpotifyPlaylistSongsResponse: Codable {
    
    let items: [SpotifyPlaylistSong]

}

struct SpotifyAlbumSongsResponse: Codable {
    
    let items: [SpotifyAlbumSong]

}

struct SpotifySearchAlbumsResponse: Codable {
    
    struct AlbumItems: Codable {
        let items: [SpotifyAlbum]
    }
    
    let albums: AlbumItems

}

typealias SpotifyUserInfoResponse = SpotifyUserInfo

typealias SpotifyArtistResponse = SpotifyFullArtist
