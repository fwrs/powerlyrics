//
//  SpotifyToken.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/23/20.
//

import Foundation

struct SpotifyToken: Codable {
    
    var accessToken: String
    var expiresIn: Int
    var refreshToken: String?
    var tokenType: String
    var saveTime: TimeInterval?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case saveTime
    }
    
    init?(data: Data, refreshToken oldRefreshToken: String? = nil) {
        guard let newToken = try? JSONDecoder().decode(SpotifyToken.self, from: data) else { return nil }
        self = newToken
        saveTime = Date.timeIntervalSinceReferenceDate
        if let oldRefreshToken = oldRefreshToken {
            refreshToken = oldRefreshToken
        }
    }

    var isExpired: Bool {
        Date.timeIntervalSinceReferenceDate - (saveTime ?? 0) > Double(expiresIn)
    }

}
