//
//  SongListViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/14/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit
import RealmSwift

// MARK: - Constants

fileprivate extension Constants {
    
    static let trendingTitle = "trending"
    
    static let viralTitle = "viral"
    
    static let likedSongsTitle = "liked songs"
    
}

// MARK: - SongListCell

enum SongListCell: Equatable {
    case song(SongCellViewModel)
    case loading
}

// MARK: - SongListViewModel

class SongListViewModel: ViewModel {
    
    // MARK: - DI

    let spotifyProvider: SpotifyProvider
    
    let realmService: RealmServiceProtocol
    
    // MARK: - Instance methods
    
    let flow: SongListFlow
    
    // MARK: - Observables
    
    let title = Observable(String())
    
    let items = MutableObservableArray<SongListCell>()
    
    let isLoadingWithPreview = Observable(false)
    
    // MARK: - Init
    
    init(flow: SongListFlow, spotifyProvider: SpotifyProvider, realmService: RealmServiceProtocol) {
        self.flow = flow
        self.spotifyProvider = spotifyProvider
        self.realmService = realmService
        super.init()
        updateTitle()
    }
    
    // MARK: - Load data
    
    func loadData(refresh: Bool = false) {
        switch flow {
        case .albumTracks(let album):
            startLoading(refresh)
            spotifyProvider.reactive
                .request(.albumSongs(albumID: album.id))
                .map(SpotifyAlbumSongsResponse.self)
                .start { [self] event in
                    switch event {
                    case .value(let response):
                        let albumSongs = response.items
                        items.replace(
                            with: albumSongs
                                .map { .song(SongCellViewModel(song: $0.asSharedSong(with: album))) },
                            performDiff: true
                        )
                        endLoading(refresh)
                        isFailed.value = false
                    case .failed:
                        items.replace(with: [], performDiff: true)
                        isFailed.value = true
                        endLoading(refresh)
                    default:
                        break
                    }
                }
        case .trendingSongs(let preview):
            isFailed.value = false
            isLoadingWithPreview.value = true
            if refresh {
                startLoading(refresh)
            }
            items.replace(with: preview.enumerated().map { .song(SongCellViewModel(song: $1, accessory: .ranking(nth: $0 + 1))) } + [.loading], performDiff: true)
            spotifyProvider.reactive
                .request(.trendingSongs)
                .map(SpotifyPlaylistSongsResponse.self)
                .start { [self] event in
                    switch event {
                    case .value(let response):
                        let trendingSongs = response.items
                        items.replace(
                            with: trendingSongs.enumerated()
                                .map { .song(SongCellViewModel(song: $1.asSharedSong, accessory: .ranking(nth: $0 + .one))) },
                            performDiff: true
                        )
                        endLoading(refresh)
                        isLoadingWithPreview.value = false
                    case .failed:
                        items.replace(with: [], performDiff: true)
                        isFailed.value = true
                        endLoading(refresh)
                        isLoadingWithPreview.value = false
                    default:
                        break
                    }
                }
        case .viralSongs(let preview):
            isLoadingWithPreview.value = true
            isFailed.value = false
            if refresh {
                startLoading(refresh)
            }
            items.replace(with: preview.enumerated().map { .song(SongCellViewModel(song: $1, accessory: .ranking(nth: $0 + .one))) } + [.loading], performDiff: true)
            spotifyProvider.reactive
                .request(.viralSongs)
                .map(SpotifyPlaylistSongsResponse.self)
                .start { [self] event in
                    switch event {
                    case .value(let response):
                        let viralSongs = response.items
                        items.replace(
                            with: viralSongs.enumerated()
                                .map { .song(SongCellViewModel(song: $1.asSharedSong, accessory: .ranking(nth: $0 + .one))) },
                            performDiff: true
                        )
                        endLoading(refresh)
                        isLoadingWithPreview.value = false
                    case .failed:
                        items.replace(with: [], performDiff: true)
                        isFailed.value = true
                        endLoading(refresh)
                        isLoadingWithPreview.value = false
                    default:
                        break
                    }
                }
        case .likedSongs:
            isFailed.value = false
            if refresh {
                startLoading(refresh)
            }
            let likedSongs = realmService.likedSongs()
            items.replace(with: likedSongs.map { .song(SongCellViewModel(song: $0.asSharedSong, accessory: .likeLogo)) }, performDiff: true)
            endLoading(refresh)
        }
    }
    
    // MARK: - Helper methods
    
    func updateTitle() {
        switch flow {
        case .albumTracks(let album):
            title.value = album.name
        case .trendingSongs:
            title.value = Constants.trendingTitle
        case .viralSongs:
            title.value = Constants.viralTitle
        case .likedSongs:
            title.value = Constants.likedSongsTitle
        }
    }
    
}
