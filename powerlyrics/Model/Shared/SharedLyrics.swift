//
//  Lyrics.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/24/20.
//

import Foundation

extension Shared {
    
    struct LyricsSection {
        var name: String?
        var contents: [String]
    }
    
    typealias Lyrics = [LyricsSection]
    
}

typealias DefaultLyricsAction = (Shared.Lyrics) -> Void
