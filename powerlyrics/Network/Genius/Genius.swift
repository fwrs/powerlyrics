//
//  Genius.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/24/20.
//

import Moya

enum Genius: TargetType {
    
    // MARK: - Requests
    
    case searchSongs(query: String)
    case getSong(id: Int)
    
    // MARK: - Requests Data
    
    var baseURL: URL {
        URL(string: "https://api.genius.com")!
    }
    
    var path: String {
        switch self {
        case .searchSongs:
            return "/search"
        case .getSong(let id):
            return "/songs/\(id)"
        }
    }
    
    var headers: [String: String]? {
        [:]
    }
    
    var method: Moya.Method {
        .get
    }
    
    var task: Task {
        switch self {
        case .searchSongs(let query):
            return .requestParameters(parameters: [
                "q": query
            ], encoding: URLEncoding.queryString)
        case .getSong:
            return .requestParameters(parameters: [
                "text_format": "plain"
            ], encoding: URLEncoding.queryString)
        }
    }
    
    var sampleData: Data { fatalError("Not used") }
    
}
