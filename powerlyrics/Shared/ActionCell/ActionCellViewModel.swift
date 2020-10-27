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
    
    var localizedTitle: String {
        if self == .signOut {
            return "Sign Out"
        }
        return "Action"
    }
}

struct ActionCellViewModel: Equatable {
    let action: ActionCellAction
}
