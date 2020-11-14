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

    func configure(with viewModel: GenreInfoCellViewModel) {
        emojiLabel.text = viewModel.level.emoji
        descriptionLabel.text = viewModel.level.localizedDescription(count: viewModel.count, genre: viewModel.genre)
    }
    
}
