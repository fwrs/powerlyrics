//
//  StatsCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/31/20.
//

import UIKit

class StatsCell: TableViewCell {
    
    @IBOutlet private weak var likedSongsCountLabel: UILabel!
    
    @IBOutlet private weak var searchesCountLabel: UILabel!
    
    @IBOutlet private weak var newDiscoveriesCountLabel: UILabel!
    
    @IBOutlet private weak var viewedArtistsLabel: UILabel!
    
    @IBOutlet private var iconImageView: [UIImageView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImageView.enumerated().forEach { index, element in
            element.image = element.image?.withTintColor([
                UIColor.systemRed, .systemYellow, .systemBlue, .systemGreen
            ][index], renderingMode: .alwaysOriginal)
        }
    }
    
    func configure(with viewModel: StatsCellViewModel) {
        
    }
    
}
