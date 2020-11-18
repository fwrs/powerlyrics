//
//  LoadingCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 15.11.20.
//

import UIKit

class LoadingCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for view in subviews where view != contentView {
            view.removeFromSuperview()
        }
    }
    
}
