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
        delay(0.1) { [self] in
            isLoading.value = false
            delay(0.1) {
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
                    ),
                    SongCellViewModel(
                        songName: "43243",
                        artistName: "bfdb",
                        albumArt: UIImage.from(color: .orange)
                    ),
                    SongCellViewModel(
                        songName: "423",
                        artistName: "bsfdb",
                        albumArt: UIImage.from(color: .magenta)
                    ),
                    SongCellViewModel(
                        songName: "rere",
                        artistName: "bsab",
                        albumArt: UIImage.from(color: .systemRed)
                    ),
                    SongCellViewModel(
                        songName: "rerewwre",
                        artistName: "aaaa",
                        albumArt: UIImage.from(color: .blue)
                    ),
                    SongCellViewModel(
                        songName: "rewrew",
                        artistName: "bbasa",
                        albumArt: UIImage.from(color: .cyan)
                    ),
                    SongCellViewModel(
                        songName: "rwerwe",
                        artistName: "bdsab",
                        albumArt: UIImage.from(color: .tintColor)
                    ),
                    SongCellViewModel(
                        songName: "rwe2132rew",
                        artistName: "bdassd3213ab",
                        albumArt: UIImage.from(color: .systemBlue)
                    ),
                    SongCellViewModel(
                        songName: "rwerefsdfdsw",
                        artistName: "bdassdab",
                        albumArt: UIImage.from(color: .systemTeal)
                    ),
                    SongCellViewModel(
                        songName: "rwersfdsfdsfdsew",
                        artistName: "fsddfsfd",
                        albumArt: UIImage.from(color: .systemOrange)
                    ),
                    SongCellViewModel(
                        songName: "rwedfsfdsfsrew",
                        artistName: "fdsfsd",
                        albumArt: UIImage.from(color: .systemYellow)
                    )
                ], performDiff: true)
            }
        }
    }
    
}
