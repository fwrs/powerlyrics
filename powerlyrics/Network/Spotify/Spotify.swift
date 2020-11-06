//
//  Spotify.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Moya

enum Spotify: TargetType {
    
    // MARK: - Requests
    
    case refreshToken(oldToken: Spotify.Token)
    case newToken(authCode: String)
    case newLocalToken
    
    case playerStatus
    case playlistSongs(playlistID: String)
    case searchAlbums(query: String)
    case userInfo
    
    static let trendingSongs = Spotify.playlistSongs(playlistID: "37i9dQZEVXbMDoHDwVN2tF")
    static let viralSongs = Spotify.playlistSongs(playlistID: "37i9dQZEVXbLiRSasKsNU9")
    
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
        case .searchAlbums:
            return "/search"
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
                "grant_type": "refresh_token",
                "refresh_token": oldToken.refreshToken.safe
            ], encoding: URLEncoding.httpBody)
        case .newToken(let authCode):
            return .requestParameters(parameters: [
                "client_id": Tokens.Spotify.clientID,
                "client_secret": Tokens.Spotify.clientSecret,
                "grant_type": "authorization_code",
                "code": authCode,
                "redirect_uri": Tokens.Spotify.redirectURL
            ], encoding: URLEncoding.httpBody)
        case .newLocalToken:
            return .requestParameters(parameters: [
                "grant_type": "client_credentials"
            ], encoding: URLEncoding.httpBody)
        case .searchAlbums(let query):
            return .requestParameters(parameters: [
                "q": query,
                "type": "album",
                "limit": 3
            ], encoding: URLEncoding.queryString)
        default:
            return .requestPlain
        }
    }
    
    var sampleData: Data { fatalError("Not used") }
    
}