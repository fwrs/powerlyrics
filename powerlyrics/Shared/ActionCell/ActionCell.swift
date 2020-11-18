//
//  ActionCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/8/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

class ActionCell: TableViewCell {
    
    @IBOutlet private weak var actionLabel: UILabel!
    
    func configure(with viewModel: ActionCellViewModel) {
        actionLabel.text = viewModel.action.localizedTitle
    }
    
}
