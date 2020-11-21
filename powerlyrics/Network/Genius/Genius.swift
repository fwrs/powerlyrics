//
//  Genius.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/24/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Moya

// MARK: - Constants

fileprivate extension Constants {
    
    static let plainTextFormat = "plain"
    
}

// MARK: - Genius

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
                "text_format": Constants.plainTextFormat
            ], encoding: URLEncoding.queryString)
        }
    }
    
    var sampleData: Data { fatalError("Not used") }
    
}
