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

class SongCell: TableViewCell {
    
    fileprivate enum Constants {
        static let albumArtShadowOpacity: Float = 0.3
    }
    
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
    
    var dominantColor: UIColor?
    
    var songContainer: UIView {
        songView
    }
    
    var currentImage: UIImage? {
        albumArtImageView.image
    }
    
    private var fullImage: SharedImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        albumArtContainerView.shadow(
            color: .black,
            radius: 6,
            offset: CGSize(width: 0, height: 3),
            opacity: Constants.albumArtShadowOpacity,
            viewCornerRadius: 8,
            viewSquircle: true
        )
        
        let interaction = UIContextMenuInteraction(delegate: self)
        albumArtImageView.addInteraction(interaction)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let highlightColor = dominantColor?.adjust(hueBy: 1, saturationBy: 1, brightnessBy: 1.5) ?? Asset.Colors.highlightCellColor.color
        let baseColor = dominantColor ?? Asset.Colors.normalCellColor.color
        UIView.animate(withDuration: (highlighted || !animated) ? 0.03 : 0.3) { [self] in
            backgroundColorView.backgroundColor = highlighted ? highlightColor : (dominantColor ?? .clear)
            accessoryBackgroundView.backgroundColor = highlighted ? highlightColor : baseColor
        }
        UIView.transition(with: accessoryFadeOutView, duration: (highlighted || !animated) ? 0.03 : 0.3, options: .transitionCrossDissolve) { [self] in
            (accessoryFadeOutView.gradientLayer).colors = highlighted ?
                [highlightColor.withAlphaComponent(0).cgColor, highlightColor.cgColor] :
                [baseColor.withAlphaComponent(0).cgColor, baseColor.cgColor]
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let highlightColor = dominantColor?.adjust(hueBy: 1, saturationBy: 1, brightnessBy: 1.5) ?? Asset.Colors.highlightCellColor.color
        let baseColor = dominantColor ?? Asset.Colors.normalCellColor.color
        UIView.animate(withDuration: (selected || !animated) ? 0.03 : 0.3) { [self] in
            backgroundColorView.backgroundColor = selected ? highlightColor : (dominantColor ?? .clear)
            accessoryBackgroundView.backgroundColor = selected ? highlightColor : baseColor
        }
        UIView.transition(with: accessoryFadeOutView, duration: (selected || !animated) ? 0.03 : 0.3, options: .transitionCrossDissolve) { [self] in
            (accessoryFadeOutView.gradientLayer).colors = selected ?
                [highlightColor.withAlphaComponent(0).cgColor, highlightColor.cgColor] :
                [baseColor.withAlphaComponent(0).cgColor, baseColor.cgColor]
        }
    }
    
    static var storedColors: [SharedSong: UIColor] = [:]
    
    func configure(with viewModel: SongCellViewModel) {
        songLabel.text = viewModel.song.name.typographized
        artistLabel.text = viewModel.song.artistsString.typographized
        backgroundColorView.backgroundColor = .clear
        albumArtImageView.populate(with: viewModel.song.thumbnailAlbumArt) { [self] result in
            if case .success(let value) = result, viewModel.shouldDisplayDominantColor {
                if let color = SongCell.storedColors[viewModel.song] {
                    (accessoryFadeOutView.gradientLayer).colors = [color.withAlphaComponent(0).cgColor, color.cgColor]
                    accessoryBackgroundView.backgroundColor = color
                    dominantColor = color
                    return
                }
                value.image.getColors(quality: .lowest, { colors in
                    let color = colors?.primary.adjust(hueBy: 1, saturationBy: 1, brightnessBy: 0.5) ?? .clear
                    backgroundColorView.backgroundColor = color
                    (accessoryFadeOutView.gradientLayer).colors = [color.withAlphaComponent(0).cgColor, color.cgColor]
                    accessoryBackgroundView.backgroundColor = color
                    dominantColor = color

                    SongCell.storedColors[viewModel.song] = color
                })
            }
        }
        if !viewModel.shouldDisplayDominantColor {
            dominantColor = nil
            (accessoryFadeOutView.gradientLayer).colors = [Asset.Colors.normalCellColor.color.withAlphaComponent(0).cgColor, Asset.Colors.normalCellColor.color.cgColor]
            accessoryBackgroundView.backgroundColor = Asset.Colors.normalCellColor.color
            backgroundColorView.backgroundColor = .clear
        }
        fullImage = viewModel.song.albumArt
        
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

extension SongCell: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard albumArtImageView.loaded else { return nil }
        UIView.animate(withDuration: 0.2, delay: 0.5) { [self] in
            albumArtContainerView.layer.shadowOpacity = 0
        }
        let controller = ImagePreviewController(fullImage, placeholder: albumArtImageView.image)
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: { controller },
            actionProvider: { _ in
                UIMenu(children: [UIAction(
                    title: "Copy",
                    image: UIImage(systemName: "doc.on.doc"),
                    identifier: nil,
                    attributes: []) { _ in
                    if let image = controller?.imageView.image {
                        UIPasteboard.general.image = image
                    }
                }] + [UIAction(
                    title: "Download",
                    image: UIImage(systemName: "square.and.arrow.down"),
                    identifier: nil,
                    attributes: []) { [self] _ in
                    if let image = controller?.imageView.image {
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
                    }
                }] + [UIAction(
                    title: "Share",
                    image: UIImage(systemName: "square.and.arrow.up"),
                    identifier: nil,
                    attributes: []) { [self] _ in
                    if let image = controller?.imageView.image {
                        window?.topViewController?.present(UIActivityViewController(activityItems: [image], applicationActivities: nil), animated: true, completion: nil)
                    }
                }])
            }
        )
    }
    
    @objc private func image(image: UIImage!, didFinishSavingWithError error: NSError!, contextInfo: AnyObject!) {
        if error != nil {
            window?.topViewController?.present(UIAlertController(title: "Failed to save image", message: "Please check application permissions and try again.", preferredStyle: .alert).with { $0.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))}, animated: true, completion: nil)
        } else {
            Haptic.play(".-O")
            window?.topViewController?.present(UIAlertController(title: "Image saved successfuly", message: "Check your gallery to find it.", preferredStyle: .alert).with { $0.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))}, animated: true, completion: nil)
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        UIView.animate(withDuration: 0.2, delay: 0.3) { [self] in
            albumArtContainerView.layer.shadowOpacity = Constants.albumArtShadowOpacity
        }
    }
    
}
