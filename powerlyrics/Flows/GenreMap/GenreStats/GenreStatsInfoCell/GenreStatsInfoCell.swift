//
//  GenreStatsInfoCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/8/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

// MARK: - Constants

fileprivate extension Constants {
    
    static let lineSpacing: CGFloat = 2
    static let boldFont = UIFont.systemFont(ofSize: 18, weight: .bold)
    static let hereSongTextPlural = "Here’s the songs:"
    static let hereSongTextSingular = "Here’s the song:"
    
}

// MARK: - GenreStatsInfoCell

class GenreStatsInfoCell: TableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var emojiLabel: UILabel!
    
    @IBOutlet private weak var descriptionLabel: UILabel!

    @IBOutlet private weak var songsLabel: UILabel!
    
    // MARK: - Configure
    
    func configure(with viewModel: GenreStatsInfoCellViewModel) {
        let text = viewModel.level.localizedDescription(count: viewModel.count, genre: viewModel.genre)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = Constants.lineSpacing

        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: .zero, length: attrString.length))
        
        attrString.addAttribute(.font, value: Constants.boldFont, range: NSString(string: text).range(of: viewModel.genre.localizedName))

        attrString.addAttribute(.font, value: Constants.boldFont, range: NSString(string: text).range(of: String(viewModel.count)))

        emojiLabel.text = viewModel.level.emoji
        descriptionLabel.attributedText = attrString
        songsLabel.text = viewModel.count == .one ? Constants.hereSongTextSingular : Constants.hereSongTextPlural
    }
    
}
