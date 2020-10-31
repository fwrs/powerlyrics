//
//  StatsCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/31/20.
//

import UIKit

class StatsCell: TableViewCell {
    
    @IBOutlet weak var likedCountLabel: UILabel!
    
    @IBOutlet weak var searchesCountLabel: UILabel!
    
    @IBOutlet weak var discoveriesCountLabel: UILabel!
    
    @IBOutlet weak var artistsLabel: UILabel!
    
    @IBOutlet var iconImageView: [UIImageView]!
    
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
