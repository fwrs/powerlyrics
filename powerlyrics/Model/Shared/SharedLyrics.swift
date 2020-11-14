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
    
    struct LyricsResult {
        
        let lyrics: Lyrics
        let genre: RealmLikedSongGenre
        let notes: String
        
    }
    
}

typealias DefaultLyricsAction = (Shared.Lyrics) -> Void
typealias DefaultLyricsResultAction = (Shared.LyricsResult) -> Void
