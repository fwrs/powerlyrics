//
//  TrendCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/30/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import ReactiveKit

class TrendCell: CollectionViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var mainButton: UIButton!
    
    // MARK: - Instance properties
    
    var didTap: DefaultAction?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: TrendCellViewModel) {
        mainButton.setTitle(viewModel.song.name, for: .normal)
        mainButton.reactive.tap.observeNext { [weak self] _ in
            self?.didTap?()
        }.dispose(in: disposeBag)
    }

}
