//
//  RealmStats.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/6/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import RealmSwift

class RealmStats: Object {

    @objc dynamic var searches = Int.zero
    
    let discoveries = List<Int>()
    let viewedArtists = List<Int>()

}
