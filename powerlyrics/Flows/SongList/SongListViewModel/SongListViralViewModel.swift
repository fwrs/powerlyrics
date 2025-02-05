//
//  SongListViralViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/20/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit

// MARK: - SongListViralViewModel

class SongListViralViewModel: SongListViewModel {

    // MARK: - Instance properties
    
    let preview: [SharedSong]
    
    // MARK: - Init
    
    init(preview: [SharedSong], spotifyProvider: SpotifyProvider, realmService: RealmServiceProtocol) {
        self.preview = preview
        super.init(spotifyProvider: spotifyProvider, realmService: realmService)
    }
    
    // MARK: - Load data
    
    override func loadData(refresh: Bool = false, retry: Bool = false) {
        isLoadingWithPreview.value = true
        isFailed.value = false
        if refresh {
            startLoading(refresh)
        }
        if retry {
            startLoading(false)
        }
        if !refresh && !retry {
            items.replace(
                with: preview.enumerated().map {
                    .song(SongCellViewModel(
                        song: $1,
                        accessory: .ranking(nth: $0 + 1)
                    ))
                } + [.loading],
                performDiff: false
            )
        }
        spotifyProvider.reactive
            .request(.viralSongs)
            .map(SpotifyPlaylistSongsResponse.self)
            .start { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .value(let response):
                    let trendingSongs = response.items
                    self.items.replace(
                        with: trendingSongs.enumerated()
                            .map { .song(SongCellViewModel(
                                song: $1.asSharedSong,
                                accessory: .ranking(nth: $0 + 1)
                            )) },
                        performDiff: true
                    )
                    self.endLoading(refresh)
                    if retry {
                        self.endLoading(false)
                    }
                    self.isLoadingWithPreview.value = false
                    
                case .failed:
                    self.items.replace(with: [], performDiff: true)
                    delay(Constants.defaultAnimationDuration) {
                        if retry {
                            self.endLoading(false)
                        }
                        self.isFailed.value = true
                        self.isLoadingWithPreview.value = false
                    }
                    if !retry {
                        self.endLoading(refresh)
                    }
                    
                default:
                    break
                }
            }
    }
    
}
