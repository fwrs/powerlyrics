//
//  SongCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Haptica
import Kingfisher
import UIKit

// MARK: - Constants

fileprivate extension Constants {
    
}

// MARK: - SongCell

class SongCell: TableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var backgroundColorView: UIView!
    
    @IBOutlet private weak var songView: UIView!
    
    @IBOutlet private weak var albumArtContainerView: UIView!
    
    @IBOutlet private weak var albumArtImageView: UIImageView!
    
    @IBOutlet private weak var songLabel: UILabel!
    
    @IBOutlet private weak var artistLabel: UILabel!
    
    @IBOutlet private weak var accessoryBackgroundView: UIView!
    
    @IBOutlet private weak var accessoryFadeOutView: GradientView!
    
    @IBOutlet private weak var accessoryStackView: UIStackView!
    
    // MARK: - Accessory outlets
    
    @IBOutlet private weak var spotifyLogoAccessoryView: UIImageView!
    
    @IBOutlet private weak var heartIconAccessoryView: UIImageView!
    
    @IBOutlet private weak var nthPlaceAccessoryView: UIStackView!
    
    @IBOutlet private weak var nthPlaceAccessoryLabel: UILabel!
    
    // MARK: - Instance properties
    
    var dominantColor: UIColor?
    
    var songContainer: UIView {
        songView
    }
    
    var currentImage: UIImage? {
        albumArtImageView.image
    }
    
    var contextMenuHandler: ImageContextMenuInteractionHandler?
    
    // MARK: - Static properties
    
    static var storedColors: [SharedSong: UIColor] = [:]
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        albumArtContainerView.shadow(
            color: .black,
            radius: 6,
            offset: CGSize(width: 0, height: 3),
            opacity: Constants.defaultShadowOpacity,
            viewCornerRadius: 8,
            viewSquircle: true
        )
        let contextMenuHandler = ImageContextMenuInteractionHandler(shadowFadeView: albumArtContainerView, imageView: albumArtImageView)
        self.contextMenuHandler = contextMenuHandler
        let interaction = UIContextMenuInteraction(delegate: contextMenuHandler)
        albumArtImageView.addInteraction(interaction)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let highlightColor = dominantColor?.adjust(brightnessBy: .oneHalfth) ?? Asset.Colors.highlightCellColor.color
        let baseColor = dominantColor ?? Asset.Colors.normalCellColor.color
        UIView.animate(withDuration: (highlighted || !animated) ? (Constants.defaultAnimationDuration * .oOne) : Constants.defaultAnimationDuration) { [self] in
            backgroundColorView.backgroundColor = highlighted ? highlightColor : dominantColor.safe
            accessoryBackgroundView.backgroundColor = highlighted ? highlightColor : baseColor
        }
        UIView.transition(with: accessoryFadeOutView, duration: (highlighted || !animated) ? (Constants.defaultAnimationDuration * .oOne) : Constants.defaultAnimationDuration, options: .transitionCrossDissolve) { [self] in
            (accessoryFadeOutView.gradientLayer).colors = highlighted ?
                [highlightColor.transparent.cg, highlightColor.cg] :
                [baseColor.transparent.cg, baseColor.cg]
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let highlightColor = dominantColor?.adjust(brightnessBy: .oneHalfth) ?? Asset.Colors.highlightCellColor.color
        let baseColor = dominantColor ?? Asset.Colors.normalCellColor.color
        UIView.animate(withDuration: (selected || !animated) ? (Constants.defaultAnimationDuration * .oOne) : Constants.defaultAnimationDuration) { [self] in
            backgroundColorView.backgroundColor = selected ? highlightColor : dominantColor.safe
            accessoryBackgroundView.backgroundColor = selected ? highlightColor : baseColor
        }
        UIView.transition(with: accessoryFadeOutView, duration: (selected || !animated) ? (Constants.defaultAnimationDuration * .oOne) : Constants.defaultAnimationDuration, options: .transitionCrossDissolve) { [self] in
            (accessoryFadeOutView.gradientLayer).colors = selected ?
                [highlightColor.transparent.cg, highlightColor.cg] :
                [baseColor.transparent.cg, baseColor.cg]
        }
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: SongCellViewModel) {
        songLabel.text = viewModel.song.name.typographized
        artistLabel.text = viewModel.song.artistsString.typographized
        backgroundColorView.backgroundColor = .clear
        albumArtImageView.populate(with: viewModel.song.thumbnailAlbumArt) { [self] result in
            if case .success(let value) = result, viewModel.shouldDisplayDominantColor {
                if let color = SongCell.storedColors[viewModel.song] {
                    (accessoryFadeOutView.gradientLayer).colors = [color.transparent.cg, color.cg]
                    accessoryBackgroundView.backgroundColor = color
                    dominantColor = color
                    return
                }
                value.image.getColors(quality: .lowest, { colors in
                    let color = (colors?.primary.adjust(brightnessBy: .half)).safe
                    backgroundColorView.backgroundColor = color
                    (accessoryFadeOutView.gradientLayer).colors = [color.transparent.cg, color.cg]
                    accessoryBackgroundView.backgroundColor = color
                    dominantColor = color

                    SongCell.storedColors[viewModel.song] = color
                })
            }
        }
        
        if !viewModel.shouldDisplayDominantColor {
            dominantColor = nil
            (accessoryFadeOutView.gradientLayer).colors = [Asset.Colors.normalCellColor.color.transparent.cg, Asset.Colors.normalCellColor.color.cg]
            accessoryBackgroundView.backgroundColor = Asset.Colors.normalCellColor.color
            backgroundColorView.backgroundColor = .clear
        }
        
        contextMenuHandler?.updateFullImage(with: viewModel.song.albumArt)
        
        accessoryStackView.isHidden = viewModel.accessory == nil
        
        switch viewModel.accessory {
        case .spotifyLogo:
            spotifyLogoAccessoryView.isHidden = false
            heartIconAccessoryView.isHidden = true
            nthPlaceAccessoryView.isHidden = true
        case .likeLogo:
            spotifyLogoAccessoryView.isHidden = true
            heartIconAccessoryView.isHidden = false
            nthPlaceAccessoryView.isHidden = true
        case .ranking(let nth):
            spotifyLogoAccessoryView.isHidden = true
            heartIconAccessoryView.isHidden = true
            nthPlaceAccessoryView.isHidden = false
            nthPlaceAccessoryLabel.text = String(nth)
        default:
            spotifyLogoAccessoryView.isHidden = true
            heartIconAccessoryView.isHidden = true
            nthPlaceAccessoryView.isHidden = true
        }
    }
    
}
