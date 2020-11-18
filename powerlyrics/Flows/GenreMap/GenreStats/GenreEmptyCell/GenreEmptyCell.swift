//
//  GenreEmptyCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/14/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

class GenreEmptyCell: TableViewCell {

    // MARK: - Outlets
    
    @IBOutlet private weak var moonImageView: UIImageView!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        moonImageView.image = moonImageView.image?.withTintColor(.label, renderingMode: .alwaysOriginal)
    }
    
}
