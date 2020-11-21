//
//  LyricsStoryViewModel.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/21/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit

// MARK: - LyricsStoryCell

enum LyricsStoryCell: Equatable {
    
    case topPadding
    case story(LyricsStoryContentCellViewModel)
    case empty
    
}

// MARK: - LyricsStoryViewModel

struct LyricsStoryViewModel {
    
    // MARK: - Instance properties
    
    let story: String
    
    // MARK: - Observables
    
    let items = MutableObservableArray<LyricsStoryCell>()
    
    // MARK: - Load data
    
    func loadData() {
        let fixed = story.typographized.clean
        
        if fixed.count <= .two {
            items.replace(with: [.empty], performDiff: false)
        } else {
            items.replace(with: [.topPadding] + fixed
                            .split(separator: Constants.newline)
                            .map(\.clean)
                            .dedupNearby(equals: String(Constants.newline)).map {
                                .story(LyricsStoryContentCellViewModel(story: $0))
                            }, performDiff: false)
        }
    }
    
}
