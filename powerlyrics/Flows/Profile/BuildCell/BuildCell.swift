//
//  BuildCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/31/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

class BuildCell: TableViewCell {
    
    // MARK: - Outlets

    @IBOutlet private weak var label: UILabel!
    
    // MARK: - Configure

    func configure(with viewModel: BuildCellViewModel) {
        label.text = viewModel.text
    }
    
}
