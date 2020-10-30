//
//  SongCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//

import Kingfisher
import UIKit

class SongCell: TableViewCell {
    
    fileprivate enum Constants {
        static let albumArtShadowOpacity: Float = 0.3
    }
    
    @IBOutlet private weak var songView: UIView!
    
    @IBOutlet private weak var albumArtContainerView: UIView!
    
    @IBOutlet private weak var albumArtImageView: UIImageView!
    
    @IBOutlet private weak var songLabel: UILabel!
    
    @IBOutlet private weak var artistLabel: UILabel!
    
    var songContainer: UIView {
        songView
    }
    
    var currentImage: UIImage? {
        albumArtImageView.image
    }
    
    private var fullImage: Shared.Image?
    
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
    
    func configure(with viewModel: SongCellViewModel) {
        songLabel.text = viewModel.song.name.typographized
        artistLabel.text = viewModel.song.artistsString.typographized
        albumArtImageView.populate(with: viewModel.song.thumbnailAlbumArt)
        fullImage = viewModel.song.albumArt
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
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: { [self] in ImagePreviewController(fullImage, placeholder: albumArtImageView.image) },
            actionProvider: { suggestedActions in
                UIMenu(children: suggestedActions)
            }
        )
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        UIView.animate(withDuration: 0.2, delay: 0.3) { [self] in
            albumArtContainerView.layer.shadowOpacity = Constants.albumArtShadowOpacity
        }
    }
    
}
