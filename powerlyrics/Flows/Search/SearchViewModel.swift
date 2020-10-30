//
//  SearchViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//

import Bond
import ReactiveKit

enum SearchSection {
    case closestMatch
    
    var localizedTitle: String {
        "Closest Match"
    }
}

class SearchViewModel: ViewModel {
    
    let songs = MutableObservableArray2D(Array2D<SearchSection, SongCellViewModel>())
    
    let trends = MutableObservableArray<TrendCellViewModel>()
    
    let geniusProvider: GeniusProvider
    
    init(geniusProvider: GeniusProvider) {
        self.geniusProvider = geniusProvider
    }
    
    func loadTrends() {
        
    }
    
    func search(for query: String, refresh: Bool = false) {
        startLoading(refresh)
        geniusProvider.reactive
            .request(.searchSongs(query: query))
            .map(Genius.SearchResponse.self)
            .start { [self] event in
                switch event {
                case .value(let response):
                    endLoading(refresh)
                    delay(0.25) {
                        songs.set([(.closestMatch, response.response.hits.map { SongCellViewModel(song: $0.result.asSharedSong) })])
                    }
                case .failed(let error):
                    print(error)
                default:
                    break
                }
            
        }
    }
    
    func reset() {
        songs.removeAllItemsAndSections()
    }
    
}
