//
//  SongCellViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//

import UIKit

enum SongCellAccessory: Equatable {
    case spotifyLogo
    case likeLogo
    case ranking(nth: Int)
}

struct SongCellViewModel: Equatable {
    let songName: String
    let artistName: String
    var albumArt: UIImage?
    var accessory: SongCellAccessory?
    var shouldDisplayDominantColor: Bool = false
}
