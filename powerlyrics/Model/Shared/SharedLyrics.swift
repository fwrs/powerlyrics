//
//  Lyrics.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/24/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

struct SharedLyricsSection {
    
    var name: String?
    var contents: [String]
    
}

typealias SharedLyrics = [SharedLyricsSection]

struct SharedLyricsResult {
    
    let lyrics: SharedLyrics
    let genre: RealmLikedSongGenre
    
}

typealias DefaultSharedLyricsAction = (SharedLyrics) -> Void
typealias DefaultSharedLyricsResultAction = (SharedLyricsResult) -> Void
