//
//  AlbumsCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/4/20.
//

import UIKit

class AlbumsCell: UITableViewCell {
    
    fileprivate enum Constants {
        static let albumArtShadowOpacity: Float = 0.3
    }
    
    @IBOutlet private weak var stackView: UIStackView!
    
    @IBOutlet private var albumArtContainerViews: [UIView]!
    
    @IBOutlet private var albumArtImageViews: [UIImageView]!
    
    @IBOutlet private var albumNameLabels: [UILabel]!
    
    @IBOutlet private var albumArrangedSubviews: [UIView]!
    
    private var interactors = [AlbumContextInteractor]()
    
    var fullSizeImages = [SharedImage?]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        albumArtContainerViews.forEach {
            $0.shadow(
                color: .black,
                radius: 6,
                offset: CGSize(width: 0, height: 3),
                opacity: Constants.albumArtShadowOpacity,
                viewCornerRadius: 8,
                viewSquircle: true
            )
        }
        interactors.removeAll()
        for (index, view) in albumArtImageViews.enumerated() {
            let interactor = AlbumContextInteractor(
                imageView: view,
                containerView: albumArtContainerViews[index],
                fullSizeImage: (self, index)
            )
            let interaction = UIContextMenuInteraction(delegate: interactor)
            interactors.append(interactor)
            view.addInteraction(interaction)
        }
        
    }
    
    func configure(with viewModel: AlbumsCellViewModel) {
        fullSizeImages.removeAll()
        for (index, album) in (0..<3).map({ viewModel.albums[safe: $0] }).enumerated() {
            if let album = album {
                albumArtImageViews[safe: index]?.populate(with: album.thumbnailAlbumArt)
                albumNameLabels[safe: index]?.text = album.name
                fullSizeImages.append(album.albumArt)
            } else {
                albumArrangedSubviews[safe: index]?.isHidden = true
            }
            stackView.spacing = index == 2 && album == nil ? 50 : 15
        }
    }
    
}

class AlbumContextInteractor: NSObject {
    
    let imageView: UIImageView
    let containerView: UIView
    let fullSizeImage: (AlbumsCell, Int)
    
    init(imageView: UIImageView, containerView: UIView, fullSizeImage: (AlbumsCell, Int)) {
        self.imageView = imageView
        self.containerView = containerView
        self.fullSizeImage = fullSizeImage
    }
    
}

extension AlbumContextInteractor: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard imageView.loaded else { return nil }
        UIView.animate(withDuration: 0.2, delay: 0.5) { [self] in
            containerView.layer.shadowOpacity = 0
        }
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: { [self] in
                ImagePreviewController(fullSizeImage.0.fullSizeImages[fullSizeImage.1], placeholder: imageView.image)
            },
            actionProvider: { suggestedActions in
                UIMenu(children: suggestedActions)
            }
        )
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        UIView.animate(withDuration: 0.2, delay: 0.3) { [self] in
            containerView.layer.shadowOpacity = AlbumsCell.Constants.albumArtShadowOpacity
        }
    }
    
}
