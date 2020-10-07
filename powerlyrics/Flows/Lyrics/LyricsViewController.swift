//
//  LyricsViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/3/20.
//

import Bond
import ReactiveKit
import UIKit

class LyricsViewController: ViewController, LyricsScene {
    
    fileprivate enum Constants {
        static let albumArtShadowOpacity: Float = 0.5
    }
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var songView: UIView!
    
    @IBOutlet private weak var albumArtContainerView: UIView!
    
    @IBOutlet private weak var albumArtImageView: UIImageView!
    
    @IBOutlet private weak var songLabel: UILabel!
    
    @IBOutlet private weak var artistLabel: UILabel!
    
    // MARK: - Instance properties

    var viewModel: LyricsViewModel!
    
    var translationInteractor: TranslationAnimationInteractor?
    
    // MARK: - Flows
    
    var flowDismiss: DefaultAction?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupObservers()
    }
    
}

extension LyricsViewController {
    
    // MARK: - Setup

    func setupView() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
            .font: FontFamily.RobotoMono.semiBold.font(size: 17)
        ]
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        navigationItem.leftBarButtonItem?.reactive.tap.observeNext { [self] _ in
            flowDismiss?()
        }.dispose(in: disposeBag)
        
        navigationItem.leftBarButtonItem?.image = navigationItem.leftBarButtonItem?.image?
            .withTintColor(UIColor.grayButtonColor, renderingMode: .alwaysOriginal)
        
        albumArtContainerView.shadow(
            color: .black,
            radius: 6,
            offset: CGSize(width: .zero, height: 3),
            opacity: Constants.albumArtShadowOpacity,
            viewCornerRadius: 8,
            viewSquircle: true
        )
        
        tableView.contentInset = UIEdgeInsets(top: 220 - safeAreaInsets.top, left: .zero, bottom: .zero, right: .zero)
        
        let interaction = UIContextMenuInteraction(delegate: self)
        albumArtImageView.addInteraction(interaction)
        
        translationInteractor = TranslationAnimationInteractor(viewController: self)
    }
    
    func setupObservers() {
        viewModel.song.observeNext { [self] song in
            songLabel.text = song.name
            artistLabel.text = song.artistName
            
            if let albumArt = song.albumArt {
                albumArtImageView.image = albumArt
            } else {
                albumArtImageView.image = UIImage.from(color: .tertiarySystemBackground)
            }
        }.dispose(in: disposeBag)
    }
    
}

extension LyricsViewController: TranslationAnimationView {
    
    var translationViews: [UIView] {
        [songView]
    }
    
}

extension LyricsViewController: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        UIView.animate(withDuration: 0.2, delay: 0.5) { [self] in
            albumArtContainerView.layer.shadowOpacity = 0
        }
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: { ImagePreviewController(self.albumArtImageView.image) },
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
