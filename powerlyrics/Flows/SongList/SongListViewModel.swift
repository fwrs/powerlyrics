//
//  SongListViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 14.11.20.
//

import Bond
import ReactiveKit
import RealmSwift

class SongListViewModel: ViewModel {
    
    let flow: SongListFlow
    
    let spotifyProvider: SpotifyProvider
    
    let title = Observable(String())
    
    let songs = MutableObservableArray<SongCellViewModel>()
    
    init(flow: SongListFlow, spotifyProvider: SpotifyProvider) {
        self.flow = flow
        self.spotifyProvider = spotifyProvider
        super.init()
        updateTitle()
    }
    
    func loadData(refresh: Bool = false) {
        startLoading(refresh)
        switch flow {
        case .albumTracks(let album):
            spotifyProvider.reactive
                .request(.albumSongs(albumID: album.id))
                .map(SpotifyAlbumSongsResponse.self)
                .start { [self] event in
                    switch event {
                    case .value(let response):
                        let albumSongs = response.items
                        songs.replace(with: albumSongs.map { SongCellViewModel(song: $0.asSharedSong(with: album)) }, performDiff: true)
                        endLoading(refresh)
                    case .failed(let error):
                        print(error)
                    default:
                        break
                    }
                }
        case .trendingSongs:
            spotifyProvider.reactive
                .request(.trendingSongs)
                .map(SpotifyPlaylistSongsResponse.self)
                .start { [self] event in
                    switch event {
                    case .value(let response):
                        let trendingSongs = response.items
                        songs.replace(with: trendingSongs.map { SongCellViewModel(song: $0.asSharedSong) }, performDiff: true)
                        endLoading(refresh)
                    case .failed(let error):
                        print(error)
                    default:
                        break
                    }
                }
        case .viralSongs:
            spotifyProvider.reactive
                .request(.viralSongs)
                .map(SpotifyPlaylistSongsResponse.self)
                .start { [self] event in
                    switch event {
                    case .value(let response):
                        let viralSongs = response.items
                        songs.replace(with: viralSongs.map { SongCellViewModel(song: $0.asSharedSong) }, performDiff: true)
                        endLoading(refresh)
                    case .failed(let error):
                        print(error)
                    default:
                        break
                    }
                }
        case .likedSongs:
            let likedSongs = Realm.likedSongs()
            songs.replace(with: likedSongs.map { SongCellViewModel(song: $0.asSharedSong) }, performDiff: true)
            endLoading(refresh)
        }
    }
    
    func updateTitle() {
        switch flow {
        case .albumTracks(let album):
            title.value = album.name
        case .trendingSongs:
            title.value = "trending songs"
        case .viralSongs:
            title.value = "viral songs"
        case .likedSongs:
            title.value = "liked songs"
        }
    }
    
}
