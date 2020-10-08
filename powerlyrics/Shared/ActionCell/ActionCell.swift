//
//  ActionCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/8/20.
//

import UIKit

class ActionCell: TableViewCell {
    
    @IBOutlet private weak var actionLabel: UILabel!
    
    func configure(with viewModel: ActionCellViewModel) {
        actionLabel.text = viewModel.action.localizedTitle
    }
    
}
