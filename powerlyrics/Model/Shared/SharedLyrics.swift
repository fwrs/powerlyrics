//
//  Lyrics.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/24/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Foundation

extension Shared {
    
    struct LyricsSection {
        var name: String?
        var contents: [String]
    }
    
    typealias Lyrics = [LyricsSection]
    
    struct LyricsResult {
        
        let lyrics: Lyrics
        let genre: RealmLikedSongGenre
        
    }
    
}

typealias DefaultLyricsAction = (Shared.Lyrics) -> Void
typealias DefaultLyricsResultAction = (Shared.LyricsResult) -> Void
