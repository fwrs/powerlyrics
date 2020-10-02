//
//  HomeViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Bond
import ReactiveKit

struct HomeViewModel {
    
    let songs = MutableObservableArray<SongCellViewModel>()
    
    let isLoading = Observable(false)
    
    init() {
        isLoading.value = true
        // simulate loading
        delay(1.8) { [self] in
            isLoading.value = false
            delay(0.2) {
                songs.replace(with: [
                    SongCellViewModel(
                        songName: "aaa",
                        artistName: "aaaa",
                        albumArt: UIImage.from(color: .red)
                    ),
                    SongCellViewModel(
                        songName: "bbb",
                        artistName: "bb",
                        albumArt: UIImage.from(color: .green)
                    )
                ], performDiff: true)
            }
        }
    }
    
}
