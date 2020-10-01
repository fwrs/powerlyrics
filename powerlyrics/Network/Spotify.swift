//
//  Spotify.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Moya

public typealias SpotifyProvider = MoyaProvider<Spotify>

public enum Spotify {
    
    case someRequest
    
}

extension Spotify: TargetType {
    
    public var baseURL: URL {
        URL(string: "https://api.spotify.com")!
    }
    
    public var path: String {
        switch self {
        case .someRequest:
            return "/someRequest"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .someRequest:
            return .get
        }
    }
    
    public var task: Task {
        switch self {
        case .someRequest:
            return .requestPlain
        }
    }
    
    public var sampleData: Data {
        Data()
    }
    
    public var headers: [String: String]? {
        ["Content-type": "application/json"]
    }
    
}
