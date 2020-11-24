//
//  SongCellViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

// MARK: - SongCellAccessory

enum SongCellAccessory: Equatable {
    
    case spotifyLogo
    case likeLogo
    case ranking(nth: Int)
    
}

// MARK: - SongCellViewModel

struct SongCellViewModel: Equatable {
    
    let song: SharedSong
    var accessory: SongCellAccessory?
    var shouldDisplayDominantColor: Bool = false
    var isInPanModal = false
    
}

extension SongCellViewModel {
    
    var cleanSongName: String { song.name.clean.typographized }
    var cleanArtistName: String { song.artistsString.clean.typographized }
    
}
