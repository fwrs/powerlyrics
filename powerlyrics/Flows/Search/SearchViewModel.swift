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
    
    var localizedDescription: String {
        "Closest Match"
    }
}

struct SearchViewModel {
    
    let songs = MutableObservableArray2D(Array2D<SearchSection, SongCellViewModel>())
    
    let isLoading = Observable(false)
    
    init() {
        songs.append(Array2D.Node.section(Array2D.Section(
            metadata: .closestMatch,
            items: [SongCellViewModel(songName: "init", artistName: "init")]
        )))
    }
    
    func search(for query: String) {
        isLoading.value = true
        delay(1) {
            songs.append(Array2D.Node.section(Array2D.Section(
                metadata: .closestMatch,
                items: [SongCellViewModel(songName: query, artistName: "init")]
            )))
            isLoading.value = false
        }
    }
    
}
