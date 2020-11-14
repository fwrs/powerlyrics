//
//  LyricsViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/3/20.
//

import Haptica
import UIKit

class LyricsViewController: ViewController, LyricsScene {
    
    fileprivate enum Constants {
        static let albumArtShadowOpacity: Float = 0.3
    }
    
    // MARK: - Outlets
    
    @IBOutlet private weak var backgroundCoverImageView: UIImageView!
    
    @IBOutlet private weak var tableView: TableView!
    
    @IBOutlet private weak var songView: UIView!
    
    @IBOutlet private weak var firstInfoLabel: UILabel!
    
    @IBOutlet private weak var secondInfoLabel: UILabel!
    
    @IBOutlet private weak var buttonsStackView: UIStackView!
    
    @IBOutlet private weak var albumArtContainerView: UIView!
    
    @IBOutlet private weak var albumArtImageView: UIImageView!
    
    @IBOutlet private weak var songLabel: UILabel!
    
    @IBOutlet private weak var artistLabel: UILabel!
    
    @IBOutlet private weak var likeButton: UIButton!
    
    @IBOutlet private weak var shareButton: UIButton!
    
    @IBOutlet private weak var safariButton: UIButton!
    
    @IBOutlet private weak var notesButton: UIButton!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var navigationBarHeightConstraint: NSLayoutConstraint!
    
    private var titleLabel: UILabel?
    
    // MARK: - Instance properties

    var viewModel: LyricsViewModel!
    
    var translationInteractor: TranslationAnimationInteractor?
    
    var albumArtThumbnail: UIImage?
    
    private var appeared: Bool = false
    
    // MARK: - Flows
    
    var flowDismiss: DefaultAction?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupObservers()
        
        viewModel.loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appeared = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appeared = false
    }
    
}

extension LyricsViewController {
    
    // MARK: - Setup

    func setupView() {
        songLabel.text = viewModel.song.name
        artistLabel.text = viewModel.song.artistsString
        albumArtImageView.populate(with: viewModel.song.thumbnailAlbumArt, placeholder: albumArtThumbnail)
        backgroundCoverImageView.populate(with: viewModel.song.thumbnailAlbumArt, placeholder: albumArtThumbnail)
    
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
        
        tableView.contentInset = UIEdgeInsets(top: 200 - safeAreaInsets.top, left: .zero, bottom: -safeAreaInsets.bottom, right: .zero)
        tableView.allowsSelection = false
        tableView.delegate = self
        
        let interaction = UIContextMenuInteraction(delegate: self)
        albumArtImageView.addInteraction(interaction)
        
        translationInteractor = TranslationAnimationInteractor(viewController: self)
        
        [likeButton, shareButton, safariButton, notesButton].forEach {
            $0?.setImage($0?.image(for: .normal)?.withTintColor(.label, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
    
    func setupObservers() {
        viewModel.lyrics.bind(to: tableView, cellType: LyricsSectionCell.self, rowAnimation: .fade) { (cell, item) in
            cell.configure(with: LyricsSectionCellViewModel(section: item))
        }.dispose(in: disposeBag)
        
        viewModel.isLoading.observeNext { [self] loading in
            UIView.animate(withDuration: 0.35) {
                activityIndicator.alpha = loading ? 1 : 0
            }
        }.dispose(in: disposeBag)
        
        likeButton.isUserInteractionEnabled = false
        viewModel.isLiked.dropFirst(1).observeNext { [self] _ in
            likeButton.isUserInteractionEnabled = true
        }.dispose(in: disposeBag)
        viewModel.isLiked.observeNext { [self] isLiked in
            UIView.transition(with: buttonsStackView, duration: 0.2, options: .transitionCrossDissolve) {
                likeButton.setImage(
                    isLiked ?
                        UIImage(systemName: "heart.fill")?.withTintColor(.label, renderingMode: .alwaysOriginal) :
                        UIImage(systemName: "heart")?.withTintColor(.label, renderingMode: .alwaysOriginal),
                    for: .normal
                )
                likeButton.setTitle(isLiked ? "liked" : "like", for: .normal)
            } completion: { _ in
                if isLiked {
                    Haptic.play(".-o")
                }
            }
        }.dispose(in: disposeBag)
        
        [likeButton, shareButton, safariButton, notesButton].forEach { button in
            button.reactive.controlEvents([.touchDown, .touchDragEnter]).observeNext { _ in
                UIView.animate(withDuration: 0.15) {
                    button.alpha = 0.5
                }
            }.dispose(in: disposeBag)
        }
        
        [likeButton, shareButton, safariButton, notesButton].forEach { button in
            button.reactive.controlEvents([.touchDragExit, .touchUpInside]).observeNext { [self] _ in
                likeButton.layer.removeAllAnimations()
                UIView.animate(withDuration: 0.15) {
                    button.alpha = 1
                }
            }.dispose(in: disposeBag)
        }
        
        likeButton.reactive.tap.throttle(for: 0.3).observeNext { [self] _ in
            guard viewModel.geniusID != nil else { return }
            if viewModel.isLiked.value {
                viewModel.unlikeSong()
            } else {
                viewModel.likeSong()
            }
        }.dispose(in: disposeBag)
    }
    
}

extension LyricsViewController: TranslationAnimationView {
    
    var translationViews: [UIView] {
        appeared && tableView.contentOffset.y > -205 ? [] : [songView]
    }
    
}

extension LyricsViewController: UIContextMenuInteractionDelegate {
    
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
            previewProvider: { [self] in ImagePreviewController(viewModel.song.albumArt, placeholder: albumArtThumbnail) },
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

extension LyricsViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let topPadding = min(270, max(44 + safeAreaInsets.top - 14, -scrollView.contentOffset.y + 12) + 14)
        navigationBarHeightConstraint.constant = topPadding
        tableView.verticalScrollIndicatorInsets.top = topPadding - safeAreaInsets.top - 44
        if scrollView.contentOffset.y >= -100 {
            navigationItem.title = songLabel.text.safe
        } else {
            navigationItem.title = "lyrics"
        }
        buttonsStackView.alpha = pow(topPadding / 270, 20)
        secondInfoLabel.alpha = pow((topPadding + 27) / 270, 20)
        firstInfoLabel.alpha = pow((topPadding + 38) / 270, 20)
        songView.alpha = pow((topPadding + 40) / 270, 7)
        let songViewAdjustment = pow((topPadding + 36) / 270, 5)
        songView.transform = .init(translationX: 0, y: -pow((1 - min((songViewAdjustment) + 0.3, 1)) * (3.68), 3) * 1.3)
    }
    
}
