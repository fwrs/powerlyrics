//
//  Spotify.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Moya

// MARK: - Constants

fileprivate extension Constants {
    
    static let trendingSongsPlaylistID = "37i9dQZEVXbMDoHDwVN2tF"
    static let viralSongsPlaylistID = "37i9dQZEVXbLiRSasKsNU9"
    
    static let refreshTokenCode = "refresh_token"
    static let authorizationCode = "authorization_code"
    static let clientCredentialsCode = "client_credentials"
    static let albumSearchType = "album"
    
    static let defaultAlbumSearchLimit = 10
    
}

// MARK: - Spotify

enum Spotify: TargetType {
    
    // MARK: - Requests
    
    case refreshToken(oldToken: SpotifyToken)
    case newToken(authCode: String)
    case newLocalToken
    
    case playerStatus
    case playlistSongs(playlistID: String)
    case albumSongs(albumID: String)
    case searchAlbums(query: String)
    case getArtist(artistID: String)
    case userInfo
    
    static let trendingSongs = Spotify.playlistSongs(playlistID: Constants.trendingSongsPlaylistID)
    static let viralSongs = Spotify.playlistSongs(playlistID: Constants.viralSongsPlaylistID)
    
    // MARK: - Requests Data
    
    var baseURL: URL {
        switch self {
        case .refreshToken, .newToken, .newLocalToken:
            return URL(string: "https://accounts.spotify.com")!
        default:
            return URL(string: "https://api.spotify.com/v1")!
        }
    }
    
    var path: String {
        switch self {
        case .refreshToken, .newToken, .newLocalToken:
            return "/api/token"
        case .playerStatus:
            return "/me/player"
        case .playlistSongs(let playlistID):
            return "/playlists/\(playlistID)/tracks"
        case .albumSongs(let albumID):
            return "/albums/\(albumID)/tracks"
        case .searchAlbums:
            return "/search"
        case .getArtist(let artistID):
            return "/artists/\(artistID)"
        case .userInfo:
            return "/me"
        }
    }
    
    var headers: [String: String]? {
        [:]
    }
    
    var method: Moya.Method {
        switch self {
        case .refreshToken, .newToken, .newLocalToken:
            return .post
        default:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .refreshToken(let oldToken):
            return .requestParameters(parameters: [
                "grant_type": Constants.refreshTokenCode,
                "refresh_token": oldToken.refreshToken.safe
            ], encoding: URLEncoding.httpBody)
        case .newToken(let authCode):
            return .requestParameters(parameters: [
                "client_id": Tokens.Spotify.clientID,
                "client_secret": Tokens.Spotify.clientSecret,
                "grant_type": Constants.authorizationCode,
                "code": authCode,
                "redirect_uri": Tokens.Spotify.redirectURL
            ], encoding: URLEncoding.httpBody)
        case .newLocalToken:
            return .requestParameters(parameters: [
                "grant_type": Constants.clientCredentialsCode
            ], encoding: URLEncoding.httpBody)
        case .searchAlbums(let query):
            return .requestParameters(parameters: [
                "q": query,
                "type": Constants.albumSearchType,
                "limit": Constants.defaultAlbumSearchLimit
            ], encoding: URLEncoding.queryString)
        default:
            return .requestPlain
        }
    }
    
    var sampleData: Data { fatalError("Not used") }
    
}
