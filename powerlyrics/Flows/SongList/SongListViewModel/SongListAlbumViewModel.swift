//
//  SongListAlbumViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/20/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit

// MARK: - SongListAlbumViewModel

class SongListAlbumViewModel: SongListViewModel {

    // MARK: - Instance properties
    
    let album: SpotifyAlbum
    
    // MARK: - Init
    
    init(album: SpotifyAlbum, spotifyProvider: SpotifyProvider, realmService: RealmServiceProtocol) {
        self.album = album
        super.init(spotifyProvider: spotifyProvider, realmService: realmService)
    }
    
    // MARK: - Load data
    
    override func loadData(refresh: Bool = false, retry: Bool = false) {
        startLoading(refresh)
        isFailed.value = false
        spotifyProvider.reactive
            .request(.albumSongs(albumID: album.id))
            .map(SpotifyAlbumSongsResponse.self)
            .start { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .value(let response):
                    let albumSongs = response.items
                    self.items.replace(
                        with: albumSongs
                            .map { .song(SongCellViewModel(song: $0.asSharedSong(with: self.album))) },
                        performDiff: true
                    )
                    self.endLoading(refresh)
                    self.isFailed.value = false
                    
                case .failed:
                    self.items.replace(with: [], performDiff: true)
                    delay(Constants.defaultAnimationDuration) {
                        self.isFailed.value = true
                        self.endLoading(refresh)
                    }
                    
                default:
                    break
                }
            }
    }
    
}
