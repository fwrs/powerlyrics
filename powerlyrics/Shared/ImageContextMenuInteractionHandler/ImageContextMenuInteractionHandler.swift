//
//  ImageContextMenuInteractionHandler.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/18/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Haptica

// MARK: - Constants

extension Constants {
    
    static let copy = (title: Strings.ContextMenu.copy, icon: UIImage(systemName: "doc.on.doc"))
    
}

fileprivate extension Constants {
    
    static let download = (title: Strings.ContextMenu.download, icon: UIImage(systemName: "square.and.arrow.down"))
    static let share = (title: Strings.ContextMenu.share, icon: UIImage(systemName: "square.and.arrow.up"))
    
    static var failedToShareAlert: UIAlertController {
        UIAlertController(
            title: Strings.ContextMenu.FailedToSave.title,
            message: Strings.ContextMenu.FailedToSave.message,
            preferredStyle: .alert
        ).with {
            $0.addAction(UIAlertAction(title: Constants.ok, style: .default, handler: nil))
        }
    }
    
    static var shareSucceededAlert: UIAlertController {
        UIAlertController(
            title: Strings.ContextMenu.SaveSucceeded.title,
            message: Strings.ContextMenu.SaveSucceeded.message,
            preferredStyle: .alert
        ).with {
            $0.addAction(UIAlertAction(title: Constants.ok, style: .default, handler: nil))
        }
    }
    
}

// MARK: - ImageContextMenuInteractionHandler

class ImageContextMenuInteractionHandler: NSObject, UIContextMenuInteractionDelegate {
    
    // MARK: - Init
    
    init(shadowFadeView: UIView? = nil, imageView: UIImageView? = nil, fullImage: SharedImage? = nil) {
        self.shadowFadeView = shadowFadeView
        self.imageView = imageView
        self.fullImage = fullImage
    }
    
    // MARK: - Public methods
    
    func updateFullImage(with newFullImage: SharedImage? = nil) {
        fullImage = newFullImage
    }
    
    // MARK: - Instance properties
    
    var shadowFadeView: UIView?
    
    var imageView: UIImageView?
    
    var fullImage: SharedImage?

    var window: UIWindow? { (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window }
    
    // MARK: - Actions
    
    @objc private func image(image: UIImage!, didFinishSavingWithError error: NSError!, contextInfo: AnyObject!) {
        if error != nil {
            window?.topViewController?.present(Constants.failedToShareAlert, animated: true, completion: nil)
        } else {
            Haptic.play(Constants.successTaps)
            window?.topViewController?.present(Constants.shareSucceededAlert, animated: true, completion: nil)
        }
    }

    // MARK: - UIContextMenuInteractionDelegate
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard imageView?.loaded == true else { return nil }
        UIView.animate(withDuration: Constants.defaultAnimationDuration, delay: 0.5) { [weak self] in
            self?.shadowFadeView?.layer.shadowOpacity = 0
        }
        let controller = ImagePreviewController(fullImage, placeholder: imageView?.image)
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: { controller },
            actionProvider: { _ in
                UIMenu(children: [
                    UIAction(
                        title: Constants.copy.title,
                        image: Constants.copy.icon,
                        identifier: nil,
                        attributes: []
                    ) { _ in
                        if let image = controller?.imageView.image {
                            UIPasteboard.general.image = image
                        }
                    },
                    UIAction(
                        title: Constants.download.title,
                        image: Constants.download.icon,
                        identifier: nil,
                        attributes: []) { [weak self] _ in
                        guard let self = self else { return }
                        if let image = controller?.imageView.image {
                            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
                        }
                    },
                    UIAction(
                        title: Constants.share.title,
                        image: Constants.share.icon,
                        identifier: nil,
                        attributes: []) { [weak self] _ in
                        if let image = controller?.imageView.image {
                            self?.window?.topViewController?.present(UIActivityViewController(
                                activityItems: [image],
                                applicationActivities: nil
                            ), animated: true, completion: nil)
                        }
                    }
                ])
            }
        )
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        UIView.animate(
            withDuration: Constants.defaultAnimationDuration,
            delay: Constants.defaultAnimationDelay
        ) { [weak self] in
            self?.shadowFadeView?.layer.shadowOpacity = Constants.defaultShadowOpacity
        }
    }
    
}
