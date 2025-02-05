//
//  SongCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Haptica
import Kingfisher

// MARK: - Constants

fileprivate extension Constants {
    
    static let normalAccessoryBackgroundWidth: CGFloat = 45
    static let compactAccessoryBackgroundWidth: CGFloat = 5
    
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
    
    // MARK: - Accessory outlets
    
    @IBOutlet private weak var accessoryBackgroundView: UIView!
    
    @IBOutlet private weak var accessoryBackgroundExtensionView: UIView!
    
    @IBOutlet private weak var accessoryFadeOutView: GradientView!
        
    @IBOutlet private weak var spotifyLogoAccessoryView: UIImageView!
    
    @IBOutlet private weak var heartIconAccessoryView: UIImageView!
    
    @IBOutlet private weak var nthPlaceAccessoryView: UIStackView!
    
    @IBOutlet private weak var nthPlaceAccessoryLabel: UILabel!
    
    @IBOutlet private weak var accessoryBackgroundViewWidthConstraint: NSLayoutConstraint!
    
    // MARK: - Static properties
    
    static var storedColors: [SharedSong: UIColor] = [:]
    
    // MARK: - Instance properties
    
    var songContainer: UIView {
        songView
    }
    
    var currentImage: UIImage? {
        albumArtImageView.image
    }
    
    var normalCellColor: UIColor = Asset.Colors.normalCellColor.color
    
    var dominantColor: UIColor?
    
    var contextMenuHandler: ImageContextMenuInteractionHandler?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        albumArtContainerView.shadow(
            color: Constants.albumArtShadowColor,
            radius: Constants.albumArtShadowRadius,
            offset: Constants.albumArtShadowOffset,
            opacity: Constants.defaultShadowOpacity,
            viewCornerRadius: Constants.albumArtShadowCornerRadius,
            viewSquircle: true
        )
        
        let contextMenuHandler = ImageContextMenuInteractionHandler(
            shadowFadeView: albumArtContainerView,
            imageView: albumArtImageView
        )
        
        self.contextMenuHandler = contextMenuHandler
        let interaction = UIContextMenuInteraction(delegate: contextMenuHandler)
        albumArtImageView.addInteraction(interaction)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let highlightColor = dominantColor?.adjust(brightnessBy: 1.5, minBrightness: 0.1) ?? Asset.Colors.highlightCellColor.color
        let baseColor = dominantColor ?? normalCellColor
        UIView.animate(withDuration: (highlighted || !animated) ? (Constants.defaultAnimationDuration * 0.1) : Constants.defaultAnimationDuration) { [weak self] in
            self?.backgroundColorView.backgroundColor = highlighted ? highlightColor : (self?.dominantColor).safe
            self?.accessoryBackgroundView.backgroundColor = highlighted ? highlightColor : baseColor
            self?.accessoryBackgroundExtensionView.backgroundColor = highlighted ? highlightColor : baseColor
        }
        UIView.fadeUpdate(accessoryFadeOutView, duration: (highlighted || !animated) ? (Constants.defaultAnimationDuration * 0.1) : Constants.defaultAnimationDuration) { [weak self] in
            self?.accessoryFadeOutView.gradientLayer.colors = highlighted ?
                [highlightColor.transparent.cg, highlightColor.cg] :
                [baseColor.transparent.cg, baseColor.cg]
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let highlightColor = dominantColor?.adjust(brightnessBy: 1.5, minBrightness: 0.1) ?? Asset.Colors.highlightCellColor.color
        let baseColor = dominantColor ?? normalCellColor
        UIView.animate(withDuration: (selected || !animated) ? (Constants.defaultAnimationDuration * 0.1) : Constants.defaultAnimationDuration) { [weak self] in
            self?.backgroundColorView.backgroundColor = selected ? highlightColor : (self?.dominantColor).safe
            self?.accessoryBackgroundView.backgroundColor = selected ? highlightColor : baseColor
            self?.accessoryBackgroundExtensionView.backgroundColor = selected ? highlightColor : baseColor
        }
        UIView.fadeUpdate(accessoryFadeOutView, duration: (selected || !animated) ? (Constants.defaultAnimationDuration * 0.1) : Constants.defaultAnimationDuration) { [weak self] in
            self?.accessoryFadeOutView.gradientLayer.colors = selected ?
                [highlightColor.transparent.cg, highlightColor.cg] :
                [baseColor.transparent.cg, baseColor.cg]
        }
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: SongCellViewModel) {
        normalCellColor = viewModel.isInsideModal ?
            Asset.Colors.normalModalCellColor.color :
            Asset.Colors.normalCellColor.color
        
        songLabel.text = viewModel.cleanSongName
        artistLabel.text = viewModel.cleanArtistName
        backgroundColorView.backgroundColor = .clear
        
        albumArtImageView.populate(with: viewModel.song.thumbnailAlbumArt) { [weak self] result in
            if case .success(let value) = result, viewModel.shouldDisplayDominantColor {
                if let color = SongCell.storedColors[viewModel.song] {
                    self?.accessoryFadeOutView.gradientLayer.colors = [color.transparent.cg, color.cg]
                    self?.accessoryBackgroundView.backgroundColor = color
                    self?.accessoryBackgroundExtensionView.backgroundColor = color
                    self?.dominantColor = color
                    return
                }
                
                value.image.getColors(quality: .lowest, { [weak self] colors in
                    guard let self = self else { return }
                    
                    let color = (colors?.primary.adjust(brightnessBy: 0.5)).safe
                    UIView.animate { [weak self] in
                        self?.backgroundColorView.backgroundColor = color
                        self?.accessoryBackgroundView.backgroundColor = color
                        self?.accessoryBackgroundExtensionView.backgroundColor = color
                    }
                    UIView.fadeUpdate(self.accessoryFadeOutView) { [weak self] in
                        self?.accessoryFadeOutView.gradientLayer.colors = [color.transparent.cg, color.cg]
                    }
                    self.dominantColor = color

                    SongCell.storedColors[viewModel.song] = color
                })
            }
        }
        
        if !viewModel.shouldDisplayDominantColor {
            dominantColor = nil
            (accessoryFadeOutView.gradientLayer).colors = [normalCellColor.transparent.cg, normalCellColor.cg]
            accessoryBackgroundView.backgroundColor = normalCellColor
            accessoryBackgroundExtensionView.backgroundColor = normalCellColor
            backgroundColorView.backgroundColor = .clear
        }
        
        contextMenuHandler?.updateFullImage(with: viewModel.song.albumArt)
        
        accessoryBackgroundViewWidthConstraint.constant = viewModel.accessory == nil ?
            Constants.compactAccessoryBackgroundWidth :
            Constants.normalAccessoryBackgroundWidth
        spotifyLogoAccessoryView.isHidden = true
        heartIconAccessoryView.isHidden = true
        nthPlaceAccessoryView.isHidden = true
    
        switch viewModel.accessory {
        case .spotifyLogo:
            spotifyLogoAccessoryView.isHidden = false
            
        case .likeLogo:
            heartIconAccessoryView.isHidden = false
            
        case .ranking(let nth):
            nthPlaceAccessoryView.isHidden = false
            nthPlaceAccessoryLabel.text = String(nth)
            
        default:
            break
        }
    }
    
}
