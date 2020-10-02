//
//  TableViewCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//

import ReactiveKit
import UIKit

class TableViewCell: UITableViewCell {
    
    let disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag.dispose()
    }
    
    deinit {
        disposeBag.dispose()
    }
    
}
