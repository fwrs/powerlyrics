//
//  ProfileStatsCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/31/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

// MARK: - Constants

fileprivate extension Constants {
    
    static let likedSongsText = (
        plural: Strings.Profile.Stats.LikedSongs.plural,
        singular: Strings.Profile.Stats.LikedSongs.singular
    )
    
    static let searchesText = (
        plural: Strings.Profile.Stats.Searches.plural,
        singular: Strings.Profile.Stats.Searches.singular
    )
    
    static let discoveriesText = (
        plural: Strings.Profile.Stats.Discoveries.plural,
        singular: Strings.Profile.Stats.Discoveries.singular
    )
    
    static let viewedArtistsText = (
        plural: Strings.Profile.Stats.ViewedArtists.plural,
        singular: Strings.Profile.Stats.ViewedArtists.singular
    )
    
}

// MARK: - ProfileStatsCell

class ProfileStatsCell: TableViewCell {
    
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
    
    func configure(with viewModel: ProfileStatsCellViewModel) {
        
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
