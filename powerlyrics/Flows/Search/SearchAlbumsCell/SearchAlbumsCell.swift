//
//  SearchAlbumsCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/4/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Haptica

// MARK: - Constants

fileprivate extension Constants {
    
    static let twoAlbumsStackViewSpacing: CGFloat = 50
    static let threeAlbumsStackViewSpacing: CGFloat = 15
    
}

// MARK: - SearchAlbumsCell

class SearchAlbumsCell: TableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var stackView: UIStackView!
    
    @IBOutlet private var albumArtContainerViews: [UIView]!
    
    @IBOutlet private var albumArtImageViews: [UIImageView]!
    
    @IBOutlet private var albumNameLabels: [UILabel]!
    
    @IBOutlet private var albumArrangedSubviews: [UIView]!
    
    // MARK: - Instance properties

    var didTapAlbum: DefaultSpotifyAlbumAction?
    
    var contextMenuHandlers = [ImageContextMenuInteractionHandler]()
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        albumArtContainerViews.forEach {
            $0.shadow(
                color: Constants.albumArtShadowColor,
                radius: Constants.albumArtShadowRadius,
                offset: Constants.albumArtShadowOffset,
                opacity: Constants.defaultShadowOpacity,
                viewCornerRadius: Constants.albumArtShadowCornerRadius,
                viewSquircle: true
            )
        }
        
        contextMenuHandlers.removeAll()
        
        for (index, view) in albumArtImageViews.enumerated() {
            let contextMenuHandler = ImageContextMenuInteractionHandler(
                shadowFadeView: albumArtContainerViews[safe: index],
                imageView: view
            )
            
            contextMenuHandlers.append(contextMenuHandler)
            let interaction = UIContextMenuInteraction(delegate: contextMenuHandler)
            view.addInteraction(interaction)
        }
        
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: SearchAlbumsCellViewModel) {
        for (index, album) in (0..<3).map({ viewModel.albums[safe: $0] }).enumerated() {
            if let album = album, album.name.nonEmpty {
                albumArtImageViews[safe: index]?.populate(with: album.thumbnailAlbumArt)
                albumNameLabels[safe: index]?.text = album.name
                contextMenuHandlers[safe: index]?.updateFullImage(with: album.albumArt)
                albumArrangedSubviews[safe: index]?.reactive.tapGesture().observeNext { [weak self] _ in
                    self?.didTapAlbum?(album)
                }.dispose(in: disposeBag)
                albumArrangedSubviews[safe: index]?.isHidden = false
            } else {
                albumArrangedSubviews[safe: index]?.isHidden = true
                albumNameLabels[safe: index]?.text = .init()
            }
            stackView.spacing = index == 2 && album == nil ?
                Constants.twoAlbumsStackViewSpacing :
                Constants.threeAlbumsStackViewSpacing
        }
    }
    
}
