//
//  LyricsStoryContentCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/21/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

// MARK: - Constants

fileprivate extension Constants {
    
    static let paragraphStyle = NSMutableParagraphStyle().with { $0.lineSpacing = 2 }
    
    static let storyFont = UIFont.systemFont(ofSize: 18)
    
}

// MARK: - LyricsStoryContentCell

class LyricsStoryContentCell: TableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var contentsLabel: CopyableLabel!

    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
        
    // MARK: - Configure
    
    func configure(with viewModel: LyricsStoryContentCellViewModel) {
        
        let attrString = NSMutableAttributedString(
            string: viewModel.text,
            attributes: [
                .paragraphStyle: Constants.paragraphStyle
            ]
        )

        contentsLabel.attributedText = attrString
        
    }
    
}
