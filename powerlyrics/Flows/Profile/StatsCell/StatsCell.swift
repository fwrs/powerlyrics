//
//  StatsCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/31/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

// MARK: - Constants

fileprivate extension Constants {
    
    static let likedSongsText = (singular: "liked song", plural: "liked songs")
    static let searchesText = (singular: "search", plural: "searches")
    static let discoveriesText = (singular: "new discovery", plural: "new discoveries")
    static let viewedArtistsText = (singular: "viewed artist", plural: "viewed artists")
    
}

// MARK: - StatsCell

class StatsCell: TableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var likedSongsDescriptionLabel: UILabel!
    
    @IBOutlet private weak var likedSongsCountLabel: UILabel!
    
    @IBOutlet private weak var searchesDescriptionLabel: UILabel!
    
    @IBOutlet private weak var searchesCountLabel: UILabel!
    
    @IBOutlet private weak var discoveriesDescriptionLabel: UILabel!
    
    @IBOutlet private weak var discoveriesCountLabel: UILabel!
    
    @IBOutlet private weak var viewedArtistsDescriptionLabel: UILabel!
    
    @IBOutlet private weak var viewedArtistsLabel: UILabel!
    
    @IBOutlet private weak var topStackView: UIStackView!
    
    @IBOutlet private weak var bottomStackView: UIStackView!
    
    @IBOutlet private weak var outerStackView: UIStackView!
    
    @IBOutlet private var iconImageView: [UIImageView]!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImageView.enumerated().forEach { index, element in
            element.image = element.image?.withTintColor([
                UIColor.systemRed, .systemYellow, .systemBlue, .systemGreen
            ][index], renderingMode: .alwaysOriginal)
        }
        
        let unifiedSpacing = UIDevice.current.hasNotch ? Constants.space20 : Constants.space16
        
        topStackView.spacing = unifiedSpacing
        bottomStackView.spacing = unifiedSpacing
        outerStackView.spacing = unifiedSpacing
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: StatsCellViewModel) {
        
        likedSongsCountLabel.text = String(viewModel.likedSongs)
        likedSongsDescriptionLabel.text = viewModel.likedSongs == .one ?
            Constants.likedSongsText.singular :
            Constants.likedSongsText.plural
        
        searchesCountLabel.text = String(viewModel.searches)
        searchesDescriptionLabel.text = viewModel.searches == .one ?
            Constants.searchesText.singular :
            Constants.searchesText.plural
        
        discoveriesCountLabel.text = String(viewModel.discoveries)
        discoveriesDescriptionLabel.text = viewModel.discoveries == .one ?
            Constants.discoveriesText.singular :
            Constants.discoveriesText.plural
        
        viewedArtistsLabel.text = String(viewModel.viewedArtists)
        viewedArtistsDescriptionLabel.text = viewModel.viewedArtists == .one ?
            Constants.viewedArtistsText.singular :
            Constants.viewedArtistsText.plural
        
    }
    
}
