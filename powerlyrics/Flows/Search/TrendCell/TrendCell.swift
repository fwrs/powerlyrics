//
//  TrendCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/30/20.
//

import Bond
import ReactiveKit
import UIKit

class TrendCell: CollectionViewCell {
    
    @IBOutlet private weak var mainButton: UIButton!
    
    var didTap: DefaultAction?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with viewModel: TrendCellViewModel) {
        mainButton.setTitle(viewModel.song.name, for: .normal)
        mainButton.reactive.tap.observeNext { [self] _ in
            didTap?()
        }.dispose(in: disposeBag)
    }

}
