//
//  LyricsViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/3/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Haptica
import UIKit

// MARK: - Constants

fileprivate extension Constants {
    
    static let heartbeatTap = ".-o--.-O"
    
    static let cutoffs: (CGFloat, CGFloat, CGFloat, CGFloat) = (27, 38, 36, 40)
    
    static let largeCutoffs: (CGFloat, CGFloat) = (100, 205)
    
    static let space7: CGFloat = 7
    
    static let space5: CGFloat = 5
    
    static let space12: CGFloat = 12
    
    static let space14: CGFloat = 14
    
    static let baseContentInset: CGFloat = 200
    
    static let baseNavigationBarHeight: CGFloat = 270
    
    static let contentInsetNotchAdjustment: CGFloat = 30
    
    static let songViewTransformYFunction = { (songViewAdjustment: CGFloat) -> CGFloat in
        (-pow((1 - min((songViewAdjustment) + 0.3, 1)) * (3.68), 3) * 1.3)
    }
    
    static let lyricsTitle = "lyrics"
    
    static let storyTitle = "Story"
    
    static let shareText = "Just discovered this awesome song using powerlyrics app:"
    
    static let producedByText = "Produced by"
    
    static let likeText = "like"
    
    static let likedText = "liked"
    
    static let fromAlbumText = "From album"
    
    static let notFoundSpotifyAlert = UIAlertController(title: "Not found", message: "We couldn’t find this item on Spotify.", preferredStyle: .alert)
    
    static let notAvailableAlert = UIAlertController(title: "Lyrics not available", message: "This song isn’t stored in the Genius database.", preferredStyle: .alert)
    
    static let filledHeartImage = UIImage(systemName: "heart.fill")!
    
    static let heartImage = UIImage(systemName: "heart")!
    
    static let storyTitleFont = UIFont.systemFont(ofSize: 16.0, weight: .medium)
    
    static let storyContentFont = UIFont.systemFont(ofSize: 14.0)
    
}

class LyricsViewController: ViewController, LyricsScene {
    
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
    
    var hasAppeared: Bool = false
    
    var contextMenuHandler: ImageContextMenuInteractionHandler?
    
    // MARK: - Flows
    
    var flowSafari: DefaultURLAction?
    
    var flowDismiss: DefaultAction?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupInput()
        setupOutput()
        
        viewModel.loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        hasAppeared = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        hasAppeared = false
    }
    
}

// MARK: - Setup

extension LyricsViewController {
    
    // MARK: - View
    
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
            Haptic.play(Constants.tinyTap)
            flowDismiss?()
        }.dispose(in: disposeBag)
        
        navigationItem.rightBarButtonItem?.reactive.tap.observeNext { [self] _ in
            if let url = viewModel.spotifyURL.value ?? viewModel.song.spotifyURL {
                Haptic.play(Constants.tinyTap)
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                present(Constants.notFoundSpotifyAlert.with {
                    $0.addAction(UIAlertAction(title: Constants.ok, style: .default, handler: nil))
                }, animated: true, completion: nil)
            }
        }.dispose(in: disposeBag)
        
        navigationItem.leftBarButtonItem?.image = navigationItem.leftBarButtonItem?.image?
            .withTintColor(UIColor.grayButtonColor, renderingMode: .alwaysOriginal)
        
        albumArtContainerView.shadow(
            color: .black,
            radius: 6,
            offset: CGSize(width: .zero, height: 3),
            opacity: Constants.defaultShadowOpacity,
            viewCornerRadius: 8,
            viewSquircle: true
        )
        
        tableView.contentInset = UIEdgeInsets(top: Constants.baseContentInset - safeAreaInsets.top - (UIDevice.current.hasNotch ? .zero : Constants.contentInsetNotchAdjustment), left: .zero, bottom: -safeAreaInsets.bottom, right: .zero)
        tableView.allowsSelection = false
        tableView.delegate = self
        
        let contextMenuHandler = ImageContextMenuInteractionHandler(
            shadowFadeView: albumArtContainerView,
            imageView: albumArtImageView,
            fullImage: viewModel.song.albumArt
        )
        self.contextMenuHandler = contextMenuHandler
        let interaction = UIContextMenuInteraction(delegate: contextMenuHandler)
        albumArtImageView.addInteraction(interaction)
        
        translationInteractor = TranslationAnimationInteractor(viewController: self)
        
        [likeButton, shareButton, safariButton, notesButton].forEach {
            $0?.setImage($0?.image(for: .normal)?.withTintColor(.label, renderingMode: .alwaysOriginal), for: .normal)
        }
        
        likeButton.isUserInteractionEnabled = false
    
    }
    
    // MARK: - Input
    
    func setupInput() {
        
        [likeButton, shareButton, safariButton, notesButton].forEach { button in
            button.reactive.controlEvents([.touchDown, .touchDragEnter]).observeNext { _ in
                UIView.animate(withDuration: Constants.fastAnimationDuration) {
                    button.alpha = .half
                }
            }.dispose(in: disposeBag)
        }
        
        [likeButton, shareButton, safariButton, notesButton].forEach { button in
            button.reactive.controlEvents([.touchDragExit, .touchUpInside]).observeNext { [self] _ in
                likeButton.layer.removeAllAnimations()
                UIView.animate(withDuration: Constants.fastAnimationDuration) {
                    button.alpha = 0.8
                }
            }.dispose(in: disposeBag)
        }
        
        likeButton.reactive.tap.throttle(for: Constants.buttonThrottleTime).observeNext { [self] _ in
            guard viewModel.genre.value != nil else { return }
            if viewModel.isLiked.value {
                viewModel.unlikeSong()
                Haptic.play(Constants.tinyTap)
            } else {
                viewModel.likeSong()
                Haptic.play(Constants.heartbeatTap, delay: .pointTwo)
            }
        }.dispose(in: disposeBag)
        
        shareButton.reactive.tap.throttle(for: Constants.buttonThrottleTime).observeNext { [self] _ in
            guard let url = viewModel.geniusURL else { return }
            Haptic.play(Constants.tinyTap)
            let items = ["\(Constants.shareText) \(url.absoluteURL)"]
            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            present(activityViewController, animated: true)
        }.dispose(in: disposeBag)
        
        safariButton.reactive.tap.throttle(for: Constants.buttonThrottleTime).observeNext { [self] _ in
            guard let url = viewModel.geniusURL else { return }
            Haptic.play(Constants.tinyTap)
            flowSafari?(url)
        }.dispose(in: disposeBag)
        
        notesButton.reactive.tap.throttle(for: Constants.buttonThrottleTime).observeNext { [self] _ in
            guard let description = viewModel.description.value?.typographized else { return }
            Haptic.play(Constants.tinyTap)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.left
            paragraphStyle.lineSpacing = .half
            
            let attributedMessageText = NSMutableAttributedString(
                string: description,
                attributes: [
                    NSAttributedString.Key.paragraphStyle: paragraphStyle,
                    NSAttributedString.Key.font: Constants.storyContentFont
                ]
            )
            
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.alignment = NSTextAlignment.center
            
            let attributedTitleText = NSMutableAttributedString(
                string: Constants.storyTitle,
                attributes: [
                    NSAttributedString.Key.paragraphStyle: titleParagraphStyle,
                    NSAttributedString.Key.font: Constants.storyTitleFont
                ]
            )
            
            present(UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet).with {
                $0.addAction(UIAlertAction(title: Constants.close, style: .default, handler: nil))
                $0.setValue(attributedMessageText, forKey: "attributedMessage")
                $0.setValue(attributedTitleText, forKey: "attributedTitle")
            }, animated: true, completion: nil)
        }.dispose(in: disposeBag)
    }
    
    // MARK: - Output
    
    func setupOutput() {
        
        viewModel.lyricsNotFound.observeNext { [self] isNotFound in
            if isNotFound {
                present(Constants.notAvailableAlert.with {
                    $0.addAction(UIAlertAction(title: Constants.ok, style: .default, handler: { _ in
                        flowDismiss?()
                    }))
                }, animated: true, completion: nil)
            }
        }.dispose(in: disposeBag)
        
        viewModel.album.dropFirst(.one).observeNext { [self] album in
            let text = "\(Constants.fromAlbumText) “\(album)”"
            let attrString = NSMutableAttributedString(string: text, attributes: [.foregroundColor: UIColor.label])
            
            attrString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: .zero, length: "\(Constants.fromAlbumText) “".count))
            attrString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: text.count - .one, length: .one))
            
            firstInfoLabel.fadeUpdate {
                firstInfoLabel.attributedText = attrString
            }
        }.dispose(in: disposeBag)
        
        viewModel.producers.dropFirst(.one).observeNext { [self] producers in
            guard producers.nonEmpty else { return }
            let text = "\(Constants.producedByText) \(producers.joined(separator: " \(Constants.ampersand) "))"
            let attrString = NSMutableAttributedString(string: text, attributes: [.foregroundColor: UIColor.label])
            
            attrString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: .zero, length: "\(Constants.producedByText) ".count))
            if producers.count > .one {
                attrString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: "\(Constants.producedByText) ".count + producers.first.safe.count, length: .three))
            }
            
            secondInfoLabel.fadeUpdate {
                secondInfoLabel.attributedText = attrString
            }
        }.dispose(in: disposeBag)
        
        viewModel.lyrics.bind(to: tableView, cellType: LyricsSectionCell.self, rowAnimation: .fade) { (cell, item) in
            cell.configure(with: LyricsSectionCellViewModel(section: item))
        }.dispose(in: disposeBag)
        
        viewModel.isLoading.observeNext { [self] loading in
            activityIndicator.fadeDisplay(visible: loading)
        }.dispose(in: disposeBag)
        
        viewModel.isFailed.observeNext { [self] failed in
            setNoInternetView(isVisible: failed) {
                viewModel.loadData()
            }
        }.dispose(in: disposeBag)
        
        viewModel.isLiked.dropFirst(.one).observeNext { [self] _ in
            likeButton.isUserInteractionEnabled = true
        }.dispose(in: disposeBag)
        
        viewModel.isLiked.observeNext { [self] isLiked in
            buttonsStackView.fadeUpdate {
                likeButton.setImage(
                    isLiked ?
                        Constants.filledHeartImage.withTintColor(.label, renderingMode: .alwaysOriginal) :
                        Constants.heartImage.withTintColor(.label, renderingMode: .alwaysOriginal),
                    for: .normal
                )
                likeButton.setTitle(isLiked ? Constants.likedText : Constants.likeText, for: .normal)
            }
        }.dispose(in: disposeBag)
        
    }
    
}

// MARK: - TranslationAnimationView

extension LyricsViewController: TranslationAnimationView {
    
    var translationViews: [UIView] {
        hasAppeared && tableView.contentOffset.y > -Constants.largeCutoffs.1 ? [] : [songView]
    }
    
}

// MARK: - UITableViewDelegate

extension LyricsViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let total: CGFloat = Constants.baseNavigationBarHeight - (UIDevice.current.hasNotch ? .zero : Constants.contentInsetNotchAdjustment)
        let topPadding = min(total, max(Constants.space44 + safeAreaInsets.top - Constants.space14, -scrollView.contentOffset.y + Constants.space12) + Constants.space14)
        navigationBarHeightConstraint.constant = topPadding
        tableView.verticalScrollIndicatorInsets.top = topPadding - safeAreaInsets.top - Constants.space44
        
        if scrollView.contentOffset.y >= -Constants.largeCutoffs.0 {
            navigationItem.title = songLabel.text.safe.lowercased()
        } else {
            navigationItem.title = Constants.lyricsTitle
        }
        
        buttonsStackView.alpha = pow(topPadding / total, Constants.space20)
        secondInfoLabel.alpha = pow((topPadding + Constants.cutoffs.0) / total, Constants.space20)
        firstInfoLabel.alpha = pow((topPadding + Constants.cutoffs.1) / total, Constants.space20)
        songView.alpha = pow((topPadding + Constants.cutoffs.3) / total, Constants.space7)
        let songViewAdjustment = pow((topPadding + Constants.cutoffs.2) / total, Constants.space5)
        songView.transform = .init(
            translationX: .zero,
            y: Constants.songViewTransformYFunction(songViewAdjustment)
        )
    }
    
}
