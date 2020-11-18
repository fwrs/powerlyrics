//
//  ActionCellViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/8/20.
//

import Foundation

enum ActionCellAction: Equatable {
    case likedSongs
    case connectToSpotify
    case manageAccount
    case signOut
    case seeTrendingSongs
    case seeViralSongs
    case appSourceCode
    
    var localizedTitle: String {
        switch self {
        case .likedSongs:
            return "Liked songs"
        case .connectToSpotify:
            return "Connect to Spotify"
        case .manageAccount:
            return "Manage account"
        case .signOut:
            return "Sign out"
        case .seeTrendingSongs:
            return "Discover all trending songs"
        case .seeViralSongs:
            return "Discover all viral songs"
        case .appSourceCode:
            return "Source code"
        }
    }
}

struct ActionCellViewModel: Equatable {
    let action: ActionCellAction
}
