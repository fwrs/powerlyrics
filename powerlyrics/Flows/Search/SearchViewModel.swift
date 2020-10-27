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
    
    let geniusProvider: GeniusProvider
    
    init(geniusProvider: GeniusProvider) {
        self.geniusProvider = geniusProvider
    }
    
    func search(for query: String) {
        isLoading.value = true
        geniusProvider.reactive
            .request(.searchSongs(query: query))
            .map(Genius.SearchResponse.self)
            .start { [self] event in
                switch event {
                case .value(let response):
                    isLoading.value = false
                    songs.removeAll()
                    songs.appendSection(.closestMatch)
                    let newSongs = response.response.hits.map { $0.result.asSharedSong }
                    for song in newSongs {
                        songs.appendItem(SongCellViewModel(song: song), toSectionAt: 0)
                    }
                case .failed(let error):
                    print(error)
                default:
                    break
                }
            
        }
    }
    
}
