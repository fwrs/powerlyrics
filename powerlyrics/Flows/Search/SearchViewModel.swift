//
//  SearchViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit
import ReactiveSwift
import RealmSwift

// MARK: - Constants

fileprivate extension Constants {
    
    static let maxTrendsCount = 8
    
}

// MARK: - SearchSection

enum SearchSection {
    
    case topResult
    case songs
    case albums
    
    var localizedTitle: String {
        switch self {
        case .topResult:
            return "Top Result"
            
        case .songs:
            return "Songs"
            
        case .albums:
            return "Albums"
        }
    }
    
}

// MARK: - SearchCell

enum SearchCell: Equatable {
    case song(SongCellViewModel)
    case albums(AlbumsCellViewModel)
}

// MARK: - SearchViewModel

class SearchViewModel: ViewModel {
    
    // MARK: - DI
    
    let spotifyProvider: SpotifyProvider
    
    let geniusProvider: GeniusProvider
    
    let realmService: RealmServiceProtocol
    
    // MARK: - Instance properties
    
    var latestSearchSongsRequest: ReactiveSwift.Disposable?
    
    var latestSearchAlbumsRequest: ReactiveSwift.Disposable?
    
    var searchSongsResult = [SharedSong]()
    
    var searchAlbumsResult = [SpotifyAlbum]()
    
    // MARK: - Observables
    
    let items = MutableObservableArray2D(Array2D<SearchSection, SearchCell>())
    
    let trends = MutableObservableArray<TrendCellViewModel>()
    
    let trendsLoading = Observable(false)
    
    let nothingWasFound = Observable(false)
    
    let trendsFailed = Observable(false)
    
    // MARK: - Init
    
    init(spotifyProvider: SpotifyProvider, geniusProvider: GeniusProvider, realmService: RealmServiceProtocol) {
        self.spotifyProvider = spotifyProvider
        self.geniusProvider = geniusProvider
        self.realmService = realmService
    }
    
    // MARK: - Load data
    
    func loadTrends() {
        trendsLoading.value = true
        trendsFailed.value = false
        spotifyProvider.reactive
            .request(.trendingSongs)
            .map(SpotifyPlaylistSongsResponse.self)
            .start { [self] event in
                switch event {
                case .value(let response):
                    trends.replace(
                        with: response.items
                            .prefix(Constants.maxTrendsCount)
                            .map { $0.asSharedSong.strippedFeatures }
                            .sorted { $0.name.count < $1.name.count }
                            .map { song in
                                TrendCellViewModel(song: song)
                            },
                        performDiff: true
                    )
                    trendsLoading.value = false
                case .failed:
                    trendsFailed.value = true
                    trendsLoading.value = false
                default:
                    break
                }
            }
    }
    
    // MARK: - Search
    
    func search(for query: String, refresh: Bool = false) {
        if query.isEmpty {
            reset()
            endLoading(refresh)
            return
        }
        startLoading(refresh)
        
        let group = DispatchGroup()
        var failedGenius = false
        var failedSpotify = false
        
        group.enter()
        latestSearchSongsRequest?.dispose()
        latestSearchSongsRequest = geniusProvider.reactive
            .request(.searchSongs(query: query))
            .map(GeniusSearchResponse.self)
            .start { [self] event in
                switch event {
                case .value(let response):
                    searchSongsResult = response.response.hits.map { $0.result.asSharedSong }
                    group.leave()
                case .failed:
                    failedGenius = true
                    group.leave()
                default:
                    break
                }
        }
        
        group.enter()
        latestSearchAlbumsRequest?.dispose()
        latestSearchAlbumsRequest = spotifyProvider.reactive
            .request(.searchAlbums(query: query))
            .map(SpotifySearchAlbumsResponse.self)
            .start { [self] event in
                switch event {
                case .value(let response):
                    if response.albums.items.count > .one {
                        searchAlbumsResult = Array(response.albums.items.prefix(Constants.maxPlaylistPreviewCount))
                    } else {
                        searchAlbumsResult = []
                    }
                    group.leave()
                case .failed:
                    searchAlbumsResult = []
                    failedSpotify = true
                    group.leave()
                default:
                    break
                }
            }
        
        group.notify(queue: .main) { [self] in
            endLoading(refresh)
            
            let topResultSection = [searchSongsResult.first].compactMap { $0 }.map { SearchCell.song(SongCellViewModel(song: $0)) }
            
            let songsSection = Array(searchSongsResult.dropFirst().prefix(Constants.maxPlaylistPreviewCount).map { SearchCell.song(SongCellViewModel(song: $0)) })
            
            let albumsSection = searchAlbumsResult.isEmpty ? [] : [SearchCell.albums(AlbumsCellViewModel(albums: searchAlbumsResult))]
            
            isFailed.value = failedGenius && failedSpotify
            
            if failedGenius && failedSpotify {
                items.set([])
                return
            }
            
            nothingWasFound.value = topResultSection.isEmpty && songsSection.isEmpty && albumsSection.isEmpty
            
            realmService.incrementSearchesStat()
            
            items.set([
                (.topResult, topResultSection),
                (.songs, songsSection),
                (.albums, albumsSection)
            ])
        }
    }
    
    // MARK: - Helper methods
    
    func reset() {
        items.removeAllItemsAndSections()
        nothingWasFound.value = false
        isFailed.value = false
    }
    
}
