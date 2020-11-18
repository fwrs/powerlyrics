//
//  Cell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
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

class CollectionViewCell: UICollectionViewCell {
    
    let disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag.dispose()
    }
    
    deinit {
        disposeBag.dispose()
    }
    
}
