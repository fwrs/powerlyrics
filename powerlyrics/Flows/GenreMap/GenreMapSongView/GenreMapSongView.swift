//
//  GenreMapSongView.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/5/20.
//

import UIKit

class GenreMapSongView: View {
    
    fileprivate enum Constants {
        static let albumArtShadowOpacity: Float = 0.3
    }
    
    @IBOutlet private weak var songView: UIView!
    
    @IBOutlet private weak var songLabel: UILabel!
    
    @IBOutlet private weak var artistLabel: UILabel!

    @IBOutlet private weak var albumArtContainerView: UIView!
    
    @IBOutlet private weak var albumArtImageView: UIImageView!

    var previewImage: UIImage? {
        albumArtImageView.image
    }
    
    var didTap: DefaultAction?
    
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

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }
    
    var songViewFrame: CGRect {
        songView.frame
    }
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        .path
    }
    
    override var collisionBoundingPath: UIBezierPath {
        UIBezierPath.superellipse(in: songView.bounds.offsetBy(dx: -songView.bounds.width/2, dy: -songView.bounds.height/2), cornerRadius: CGFloat(68))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.2) { [self] in
            songView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.2) { [self] in
            songView.backgroundColor = .clear
        }
    }
    
    @IBAction private func tapped() {
        didTap?()
    }
    
    private var fullImage: Shared.Image?
    
    func configure(with viewModel: GenreMapSongViewModel) {
        songLabel.text = viewModel.song.name.typographized
        artistLabel.text = viewModel.song.artistsString.typographized
        albumArtImageView.populate(with: viewModel.song.thumbnailAlbumArt)
        fullImage = viewModel.song.albumArt
    }

}

extension GenreMapSongView: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard albumArtImageView.loaded else { return nil }
        UIView.animate(withDuration: 0.2, delay: 0.5) { [self] in
            albumArtContainerView.layer.shadowOpacity = 0
            songView.backgroundColor = .clear
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
