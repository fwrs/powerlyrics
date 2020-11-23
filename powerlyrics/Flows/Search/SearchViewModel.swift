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
            return Strings.Search.Section.topResult
            
        case .songs:
            return Strings.Search.Section.songs
            
        case .albums:
            return Strings.Search.Section.albums
        }
    }
    
}

// MARK: - SearchCell

enum SearchCell: Equatable {
    case song(SongCellViewModel)
    case albums(SearchAlbumsCellViewModel)
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
    
    let trends = MutableObservableArray<SearchTrendCellViewModel>()
    
    let trendsLoading = Observable(false)
    
    let nothingWasFound = Observable(false)
    
    let trendsFailed = Observable(false)
    
    let isCancelled = Observable(false)
    
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
            .start { [weak self] event in
                switch event {
                case .value(let response):
                    self?.trends.replace(
                        with: response.items
                            .prefix(Constants.maxTrendsCount)
                            .map {
                                $0.asSharedSong.strippedFeatures.with {
                                    $0.name = $0.name.components(
                                        separatedBy: Constants.startingParenthesis
                                    ).first.mapEmptyToNil?.clean ?? $0.name
                                }
                            }
                            .sorted { $0.name.count < $1.name.count }
                            .map { song in
                                SearchTrendCellViewModel(song: song)
                            },
                        performDiff: true
                    )
                    self?.trendsLoading.value = false
                    
                case .failed:
                    delay(Constants.defaultAnimationDuration) { [weak self] in
                        self?.trendsFailed.value = true
                        self?.trendsLoading.value = false
                    }
                    
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
        isFailed.value = false
        
        let group = DispatchGroup()
        var failedGenius = false
        var failedSpotify = false
        
        group.enter()
        latestSearchSongsRequest?.dispose()
        latestSearchSongsRequest = geniusProvider.reactive
            .request(.searchSongs(query: query))
            .map(GeniusSearchResponse.self)
            .start { [weak self] event in
                switch event {
                case .value(let response):
                    self?.searchSongsResult = response.response.hits.map { $0.result.asSharedSong }
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
            .start { [weak self] event in
                switch event {
                case .value(let response):
                    let deduplicated = response.albums.items.dedup {
                        $0.name == $1.name && $0.artists == $1.artists
                    }
                    
                    if deduplicated.nonEmpty {
                        self?.searchAlbumsResult = Array(deduplicated.prefix(Constants.maxPlaylistPreviewCount))
                    } else {
                        self?.searchAlbumsResult = []
                    }
                    
                    group.leave()
                    
                case .failed:
                    self?.searchAlbumsResult = []
                    failedSpotify = true
                    group.leave()
                    
                default:
                    break
                }
            }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            let topResultSection = [self.searchSongsResult.first].compactMap { $0 }.map { SearchCell.song(SongCellViewModel(song: $0)) }
            
            let songsSection = Array(self.searchSongsResult.dropFirst().prefix(Constants.maxPlaylistPreviewCount).map { SearchCell.song(SongCellViewModel(song: $0)) })
            
            let albumsSection = self.searchAlbumsResult.isEmpty ? [] : [SearchCell.albums(SearchAlbumsCellViewModel(albums: self.searchAlbumsResult))]
                        
            if failedGenius && failedSpotify {
                delay(Constants.defaultAnimationDuration) { [weak self] in
                    self?.isFailed.value = true
                    self?.endLoading(refresh)
                    self?.items.set([])
                }
                return
            } else {
                self.isFailed.value = false
            }
            
            self.nothingWasFound.value = topResultSection.isEmpty && songsSection.isEmpty && albumsSection.isEmpty
            
            self.realmService.incrementSearchesStat()
            
            self.items.set([
                (.topResult, topResultSection),
                (.songs, songsSection),
                (.albums, albumsSection)
            ])
            
            self.endLoading(refresh)
        }
    }
    
    // MARK: - Helper methods
    
    func reset() {
        items.removeAllItemsAndSections()
        nothingWasFound.value = false
        isFailed.value = false
        isLoading.value = false
        isRefreshing.value = false
    }
    
    func cancelLoading() {
        latestSearchSongsRequest?.dispose()
        latestSearchAlbumsRequest?.dispose()
    }
    
}
