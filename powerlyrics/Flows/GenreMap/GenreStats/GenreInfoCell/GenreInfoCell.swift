//
//  GenreInfoCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/8/20.
//

import UIKit

class GenreInfoCell: TableViewCell {
    
    @IBOutlet private weak var emojiLabel: UILabel!
    
    @IBOutlet private weak var descriptionLabel: UILabel!

    @IBOutlet private weak var songsLabel: UILabel!
    
    func configure(with viewModel: GenreInfoCellViewModel) {
        let text = viewModel.level.localizedDescription(count: viewModel.count, genre: viewModel.genre)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2

        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attrString.length))
        
        attrString.addAttribute(.font, value: UIFont.systemFont(ofSize: 18, weight: .bold), range: NSString(string: text).range(of: viewModel.genre.localizedName))

        attrString.addAttribute(.font, value: UIFont.systemFont(ofSize: 18, weight: .bold), range: NSString(string: text).range(of: String(viewModel.count)))

        emojiLabel.text = viewModel.level.emoji
        descriptionLabel.attributedText = attrString
        songsLabel.text = viewModel.count == 1 ? "Here’s the song:" : "Here’s the songs:"
    }
    
}
