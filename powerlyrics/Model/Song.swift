//
//  Song.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//

import UIKit

struct Song {
    let name: String
    let artistName: String
    let albumArt: UIImage?
}

typealias DefaultSongAction = (Song) -> Void
