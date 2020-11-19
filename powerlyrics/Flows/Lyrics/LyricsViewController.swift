//
//  LyricsViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/3/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Haptica

// MARK: - Constants

fileprivate extension Constants {
    
    // MARK: - Haptic
    
    static let heartbeatTap = ".-o--.-O"
    
    // MARK: - Numeric
    
    static let cutoffs: (CGFloat, CGFloat, CGFloat, CGFloat) = (27, 38, 36, 40)
    static let largeCutoffs: (CGFloat, CGFloat) = (100, 205)
    
    static let space7: CGFloat = 7
    static let space5: CGFloat = 5
    static let space12: CGFloat = 12
    static let space14: CGFloat = 14
    
    static let baseContentInset: CGFloat = 200
    static let baseNavigationBarHeight: CGFloat = 270
    static let contentInsetNotchAdjustment: CGFloat = 30
    
    static let lyricsTitle = "lyrics"
    static let storyTitle = "Story"
    static let shareText = "Just discovered this awesome song using powerlyrics app:"
    static let producedByText = "Produced by"
    static let likeText = "like"
    static let likedText = "liked"
    static let fromAlbumText = "From album"
    static let unknownDescriptionText = "No information"
    
    // MARK: - Alerts
    
    static var notFoundSpotifyAlert: UIAlertController {
        UIAlertController(
            title: "Not found",
            message: "We couldn’t find this item on Spotify.",
            preferredStyle: .alert
        )
    }
    
    static var notAvailableAlert: UIAlertController {
        UIAlertController(
            title: "Lyrics not available",
            message: "This song isn’t stored in the Genius database.",
            preferredStyle: .alert
        )
    }
    
    // MARK: - Icons
    
    static let filledHeartImage = UIImage(systemName: "heart.fill")!
    static let heartImage = UIImage(systemName: "heart")!
    
    static let storyTitleFont = UIFont.systemFont(ofSize: 16.0, weight: .medium)
    static let storyContentFont = UIFont.systemFont(ofSize: 14.0)
    
    // MARK: - Curves
    
    static let songViewTransformYFunction = { (songViewAdjustment: CGFloat) -> CGFloat in
        (-pow((1 - min((songViewAdjustment) + 0.3, 1)) * (3.68), 3) * 1.3) }
    
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
            .font: Constants.titleFont
        ]
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        navigationItem.leftBarButtonItem?.reactive.tap.observeNext { [weak self] _ in
            Haptic.play(Constants.tinyTap)
            self?.flowDismiss?()
        }.dispose(in: disposeBag)
        
        navigationItem.rightBarButtonItem?.reactive.tap.observeNext { [weak self] _ in
            guard let self = self else { return }
            
            if let url = self.viewModel.spotifyURL.value ?? self.viewModel.song.spotifyURL {
                Haptic.play(Constants.tinyTap)
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                self.present(Constants.notFoundSpotifyAlert.with {
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
            button.reactive.controlEvents([.touchDragExit, .touchUpInside]).observeNext { [weak self] _ in
                self?.likeButton.layer.removeAllAnimations()
                UIView.animate(withDuration: Constants.fastAnimationDuration) {
                    button.alpha = 0.8
                }
            }.dispose(in: disposeBag)
        }
        
        likeButton.reactive.tap.throttle(for: Constants.buttonThrottleTime).observeNext { [weak self] _ in
            guard let self = self, self.viewModel.genre.value != nil else { return }
            if self.viewModel.isLiked.value {
                self.viewModel.unlikeSong()
                Haptic.play(Constants.tinyTap)
            } else {
                self.viewModel.likeSong()
                Haptic.play(Constants.heartbeatTap, delay: .pointTwo)
            }
        }.dispose(in: disposeBag)
        
        shareButton.reactive.tap.throttle(for: Constants.buttonThrottleTime).observeNext { [weak self] _ in
            guard let self = self, let url = self.viewModel.geniusURL else { return }
            Haptic.play(Constants.tinyTap)
            let items = ["\(Constants.shareText) \(url.absoluteURL)"]
            let activityViewController = UIActivityViewController(
                activityItems: items,
                applicationActivities: nil
            )
            self.present(activityViewController, animated: true)
        }.dispose(in: disposeBag)
        
        safariButton.reactive.tap.throttle(for: Constants.buttonThrottleTime).observeNext { [weak self] _ in
            guard let self = self, let url = self.viewModel.geniusURL else { return }
            Haptic.play(Constants.tinyTap)
            self.flowSafari?(url)
        }.dispose(in: disposeBag)
        
        notesButton.reactive.tap.throttle(for: Constants.buttonThrottleTime).observeNext { [weak self] _ in
            guard let self = self,
                  var description = self.viewModel.description.value?.clean.typographized else { return }
            if description == Constants.question {
                description = Constants.unknownDescriptionText
            }
            
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
            
            self.present(UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet).with {
                $0.addAction(UIAlertAction(title: Constants.close, style: .default, handler: nil))
                $0.setValue(attributedMessageText, forKey: "attributedMessage")
                $0.setValue(attributedTitleText, forKey: "attributedTitle")
            }, animated: true, completion: nil)
        }.dispose(in: disposeBag)
    }
    
    // MARK: - Output
    
    func setupOutput() {
        
        viewModel.lyricsNotFound.observeNext { [weak self] isNotFound in
            guard let self = self else { return }
            if isNotFound {
                self.present(Constants.notAvailableAlert.with {
                    $0.addAction(UIAlertAction(title: Constants.ok, style: .default, handler: { _ in
                        self.flowDismiss?()
                    }))
                }, animated: true, completion: nil)
            }
        }.dispose(in: disposeBag)
        
        viewModel.album.dropFirst(.one).observeNext { [weak self] album in
            guard let self = self else { return }
            
            let text = "\(Constants.fromAlbumText) “\(album)”"
            let attrString = NSMutableAttributedString(string: text, attributes: [.foregroundColor: UIColor.label])
            
            attrString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: .zero, length: "\(Constants.fromAlbumText) “".count))
            attrString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: text.count - .one, length: .one))
            
            UIView.fadeUpdate(self.firstInfoLabel) {
                self.firstInfoLabel.attributedText = attrString
            }
        }.dispose(in: disposeBag)
        
        viewModel.producers.dropFirst(.one).observeNext { [weak self] producers in
            guard let self = self, producers.nonEmpty else { return }
            let text = "\(Constants.producedByText) \(producers.joined(separator: " \(Constants.ampersand) "))"
            let attrString = NSMutableAttributedString(string: text, attributes: [.foregroundColor: UIColor.label])
            
            attrString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: .zero, length: "\(Constants.producedByText) ".count))
            if producers.count > .one {
                attrString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: "\(Constants.producedByText) ".count + producers.first.safe.count, length: .three))
            }
            
            UIView.fadeUpdate(self.secondInfoLabel) {
                self.secondInfoLabel.attributedText = attrString
            }
        }.dispose(in: disposeBag)
        
        viewModel.lyrics.bind(to: tableView, cellType: LyricsSectionCell.self, rowAnimation: .fade) { (cell, item) in
            cell.configure(with: LyricsSectionCellViewModel(section: item))
        }.dispose(in: disposeBag)
        
        viewModel.isLoading.observeNext { [weak self] loading in
            guard let self = self else { return }
            UIView.fadeDisplay(self.activityIndicator, visible: loading)
        }.dispose(in: disposeBag)
        
        viewModel.isFailed.observeNext { [weak self] failed in
            self?.setNoInternetView(isVisible: failed) {
                self?.viewModel.loadData()
            }
        }.dispose(in: disposeBag)
        
        viewModel.isLiked.dropFirst(.one).observeNext { [weak self] _ in
            self?.likeButton.isUserInteractionEnabled = true
        }.dispose(in: disposeBag)
        
        viewModel.isLiked.observeNext { [weak self] isLiked in
            guard let self = self else { return }
            UIView.fadeUpdate(self.buttonsStackView) {
                self.likeButton.setImage(
                    isLiked ?
                        Constants.filledHeartImage.withTintColor(.label, renderingMode: .alwaysOriginal) :
                        Constants.heartImage.withTintColor(.label, renderingMode: .alwaysOriginal),
                    for: .normal
                )
                self.likeButton.setTitle(isLiked ? Constants.likedText : Constants.likeText, for: .normal)
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
