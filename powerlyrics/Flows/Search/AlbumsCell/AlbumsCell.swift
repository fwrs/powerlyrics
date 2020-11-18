//
//  AlbumsCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/4/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Haptica
import UIKit

class AlbumsCell: TableViewCell {
    
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
    
    var didTapAlbum: DefaultSpotifyAlbumAction?
    
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
                fullSizeImage: (self, index),
                window: window
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
                albumArrangedSubviews[safe: index]?.reactive.tapGesture().observeNext { [self] _ in
                    didTapAlbum?(album)
                }.dispose(in: disposeBag)
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
    weak var window: UIWindow?
    
    init(imageView: UIImageView, containerView: UIView, fullSizeImage: (AlbumsCell, Int), window: UIWindow?) {
        self.imageView = imageView
        self.containerView = containerView
        self.fullSizeImage = fullSizeImage
        self.window = window
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
        
        let controller = ImagePreviewController(fullSizeImage.0.fullSizeImages[fullSizeImage.1], placeholder: imageView.image)
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
            containerView.layer.shadowOpacity = AlbumsCell.Constants.albumArtShadowOpacity
        }
    }
    
}
