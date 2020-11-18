//
//  SongCellViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

enum SongCellAccessory: Equatable {
    case spotifyLogo
    case likeLogo
    case ranking(nth: Int)
}

struct SongCellViewModel: Equatable {
    let song: SharedSong
    var accessory: SongCellAccessory?
    var shouldDisplayDominantColor: Bool = false
}
