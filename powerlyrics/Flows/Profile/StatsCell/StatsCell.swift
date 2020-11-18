//
//  StatsCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/31/20.
//

import UIKit

class StatsCell: TableViewCell {
    
    @IBOutlet private weak var likedSongsDescriptionLabel: UILabel!
    
    @IBOutlet private weak var likedSongsCountLabel: UILabel!
    
    @IBOutlet private weak var searchesDescriptionLabel: UILabel!
    
    @IBOutlet private weak var searchesCountLabel: UILabel!
    
    @IBOutlet private weak var discoveriesDescriptionLabel: UILabel!
    
    @IBOutlet private weak var discoveriesCountLabel: UILabel!
    
    @IBOutlet private weak var viewedArtistsDescriptionLabel: UILabel!
    
    @IBOutlet private weak var viewedArtistsLabel: UILabel!
    
    @IBOutlet private var iconImageView: [UIImageView]!
    
    @IBOutlet private weak var topStackView: UIStackView!
    
    @IBOutlet private weak var bottomStackView: UIStackView!
    
    @IBOutlet private weak var outerStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImageView.enumerated().forEach { index, element in
            element.image = element.image?.withTintColor([
                UIColor.systemRed, .systemYellow, .systemBlue, .systemGreen
            ][index], renderingMode: .alwaysOriginal)
        }
        
        topStackView.spacing = UIDevice.current.hasNotch ? 20 : 16
        bottomStackView.spacing = UIDevice.current.hasNotch ? 20 : 16
        outerStackView.spacing = UIDevice.current.hasNotch ? 20 : 16
    }
    
    func configure(with viewModel: StatsCellViewModel) {
        likedSongsCountLabel.text = String(viewModel.likedSongs)
        likedSongsDescriptionLabel.text = viewModel.likedSongs == 1 ? "liked song" : "liked songs"
        searchesCountLabel.text = String(viewModel.searches)
        searchesDescriptionLabel.text = viewModel.searches == 1 ? "search" : "searches"
        discoveriesCountLabel.text = String(viewModel.discoveries)
        discoveriesDescriptionLabel.text = viewModel.discoveries == 1 ? "new discovery" : "new discoveries"
        viewedArtistsLabel.text = String(viewModel.viewedArtists)
        viewedArtistsDescriptionLabel.text = viewModel.viewedArtists == 1 ? "viewed artist" : "viewed artists"
    }
    
}
