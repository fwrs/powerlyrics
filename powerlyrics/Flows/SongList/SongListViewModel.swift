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

enum SongListCell: Equatable {
    case song(SongCellViewModel)
    case loading
}

class SongListViewModel: ViewModel {
    
    let flow: SongListFlow
    
    let spotifyProvider: SpotifyProvider
    
    let title = Observable(String())
    
    let items = MutableObservableArray<SongListCell>()
    
    let failed = Observable(false)
    
    let isLoadingWithPreview = Observable(false)
    
    init(flow: SongListFlow, spotifyProvider: SpotifyProvider) {
        self.flow = flow
        self.spotifyProvider = spotifyProvider
        super.init()
        updateTitle()
    }
    
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
                        items.replace(with: albumSongs.map { .song(SongCellViewModel(song: $0.asSharedSong(with: album))) }, performDiff: true)
                        endLoading(refresh)
                        failed.value = false
                    case .failed:
                        items.replace(with: [], performDiff: true)
                        failed.value = true
                        endLoading(refresh)
                    default:
                        break
                    }
                }
        case .trendingSongs(let preview):
            failed.value = false
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
                        items.replace(with: trendingSongs.enumerated().map { .song(SongCellViewModel(song: $1.asSharedSong, accessory: .ranking(nth: $0 + 1))) }, performDiff: true)
                        endLoading(refresh)
                        isLoadingWithPreview.value = false
                    case .failed:
                        items.replace(with: [], performDiff: true)
                        failed.value = true
                        endLoading(refresh)
                        isLoadingWithPreview.value = false
                    default:
                        break
                    }
                }
        case .viralSongs(let preview):
            isLoadingWithPreview.value = true
            failed.value = false
            if refresh {
                startLoading(refresh)
            }
            items.replace(with: preview.enumerated().map { .song(SongCellViewModel(song: $1, accessory: .ranking(nth: $0 + 1))) } + [.loading], performDiff: true)
            spotifyProvider.reactive
                .request(.viralSongs)
                .map(SpotifyPlaylistSongsResponse.self)
                .start { [self] event in
                    switch event {
                    case .value(let response):
                        let viralSongs = response.items
                        items.replace(with: viralSongs.enumerated().map { .song(SongCellViewModel(song: $1.asSharedSong, accessory: .ranking(nth: $0 + 1))) }, performDiff: true)
                        endLoading(refresh)
                        isLoadingWithPreview.value = false
                    case .failed:
                        items.replace(with: [], performDiff: true)
                        failed.value = true
                        endLoading(refresh)
                        isLoadingWithPreview.value = false
                    default:
                        break
                    }
                }
        case .likedSongs:
            failed.value = false
            if refresh {
                startLoading(refresh)
            }
            let likedSongs = Realm.likedSongs()
            items.replace(with: likedSongs.map { .song(SongCellViewModel(song: $0.asSharedSong, accessory: .likeLogo)) }, performDiff: true)
            endLoading(refresh)
        }
    }
    
    func updateTitle() {
        switch flow {
        case .albumTracks(let album):
            title.value = album.name
        case .trendingSongs:
            title.value = "trending"
        case .viralSongs:
            title.value = "viral"
        case .likedSongs:
            title.value = "liked songs"
        }
    }
    
}
