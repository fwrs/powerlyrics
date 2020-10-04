//
//  LyricsViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/3/20.
//

import Bond
import ReactiveKit
import UIKit

struct LyricsViewModel {
    
    let song: Observable<Song>
    
    init(song: Song) {
        self.song = .init(song)
    }
    
}
