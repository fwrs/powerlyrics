//
//  Local.Stats.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/6/20.
//

import Foundation
import RealmSwift

extension Local {
    
    class Stats: Object {
        @objc dynamic var likedSongs = 0
        @objc dynamic var searches = 0
        @objc dynamic var newDiscoveries = 0
        @objc dynamic var viewedArtists = 0
    }
    
}
