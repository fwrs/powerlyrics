//
//  SearchViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//

import Bond
import ReactiveKit
import ReactiveSwift

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

enum SearchCell: Equatable {
    case song(SongCellViewModel)
    case albums(AlbumsCellViewModel)
}

class SearchViewModel: ViewModel {
    
    let items = MutableObservableArray2D(Array2D<SearchSection, SearchCell>())
    
    let trends = MutableObservableArray<TrendCellViewModel>()
    
    let spotifyProvider: SpotifyProvider
    
    let geniusProvider: GeniusProvider
    
    let trendsAreLoading = Observable(true)
    
    var latestSearchSongsRequest: ReactiveSwift.Disposable?
    
    var latestSearchAlbumsRequest: ReactiveSwift.Disposable?
    
    private var searchSongsResult = [SharedSong]()
    
    private var searchAlbumsResult = [SpotifyAlbum]()
    
    init(spotifyProvider: SpotifyProvider, geniusProvider: GeniusProvider) {
        self.spotifyProvider = spotifyProvider
        self.geniusProvider = geniusProvider
    }
    
    func loadTrends() {
        spotifyProvider.reactive
            .request(.trendingSongs)
            .map(SpotifyPlaylistSongsResponse.self)
            .start { [self] event in
                switch event {
                case .value(let response):
                    trends.replace(
                        with: response.items
                            .prefix(8)
                            .map { $0.asSharedSong.strippedFeatures }
                            .sorted { $0.name.count < $1.name.count }
                            .map { song in
                                TrendCellViewModel(song: song)
                            },
                        performDiff: true
                    )
                    trendsAreLoading.value = false
                case .failed(let error):
                    print(error)
                default:
                    break
                }
            }
    }
    
    func search(for query: String, refresh: Bool = false) {
        if query.isEmpty {
            reset()
            endLoading(refresh)
            return
        }
        startLoading(refresh)
        
        let group = DispatchGroup()
        
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
                case .failed(let error):
                    print(error)
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
                    if response.albums.items.count > 1 {
                        searchAlbumsResult = Array(response.albums.items.prefix(3))
                    } else {
                        searchAlbumsResult = []
                    }
                    group.leave()
                case .failed:
                    searchAlbumsResult = []
                    group.leave()
                default:
                    break
                }
            }
        
        group.notify(queue: .main) { [self] in
            endLoading(refresh)
            
            let topResultSection = [searchSongsResult.first].compactMap { $0 }.map { SearchCell.song(SongCellViewModel(song: $0)) }
            
            let songsSection = Array(searchSongsResult.dropFirst().prefix(3).map { SearchCell.song(SongCellViewModel(song: $0)) })
            
            let albumsSection = searchAlbumsResult.isEmpty ? [] : [SearchCell.albums(AlbumsCellViewModel(albums: searchAlbumsResult))]
            
            items.set([
                (.topResult, topResultSection),
                (.songs, songsSection),
                (.albums, albumsSection)
            ])
        }
    }
    
    func reset() {
        items.removeAllItemsAndSections()
    }
    
}
