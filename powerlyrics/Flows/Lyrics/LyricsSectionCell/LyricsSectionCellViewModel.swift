//
//  LyricsSectionCellViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/24/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

struct LyricsSectionCellViewModel {
    
    let section: SharedLyricsSection
    
}

extension LyricsSectionCellViewModel {
    
    var cleanContents: String {
        section.contents.map { $0.clean }.joined(separator: String(Constants.newlineCharacter)).typographized
    }
    
}
