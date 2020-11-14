//
//  GenreEmptyCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 14.11.20.
//

import UIKit

class GenreEmptyCell: TableViewCell {

    @IBOutlet private weak var moonImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        moonImageView.image = moonImageView.image?.withTintColor(UIColor.label.withAlphaComponent(0.6), renderingMode: .alwaysOriginal)
    }
    
}
