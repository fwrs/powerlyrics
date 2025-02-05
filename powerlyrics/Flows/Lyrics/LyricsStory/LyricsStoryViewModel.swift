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
    case content(LyricsStoryContentCellViewModel)
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
        
        if fixed.count <= 2 {
            items.replace(with: [.empty], performDiff: false)
        } else {
            items.replace(with: [.topPadding] + fixed
                            .split(separator: Constants.newlineCharacter)
                            .map(\.clean)
                            .dedupNearby(equals: Constants.newline).map {
                                .content(LyricsStoryContentCellViewModel(text: $0))
                            }, performDiff: false)
        }
    }
    
}
