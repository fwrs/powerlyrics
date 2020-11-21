//
//  LoadingCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/15/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

class LoadingCell: TableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for view in subviews where view != contentView {
            view.removeFromSuperview()
        }
    }
    
}
