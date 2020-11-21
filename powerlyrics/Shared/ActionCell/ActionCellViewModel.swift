//
//  ActionCellViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/8/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

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
            return Strings.ActionCell.likedSongs
            
        case .connectToSpotify:
            return Strings.ActionCell.connectToSpotify
            
        case .manageAccount:
            return Strings.ActionCell.manageAccount
            
        case .signOut:
            return Strings.ActionCell.signOut
            
        case .seeTrendingSongs:
            return Strings.ActionCell.seeTrendingSongs
            
        case .seeViralSongs:
            return Strings.ActionCell.seeViralSongs
            
        case .appSourceCode:
            return Strings.ActionCell.appSourceCode
        }
    }
    
}

struct ActionCellViewModel: Equatable {
    
    let action: ActionCellAction
    
}
