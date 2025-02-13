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
    static let heartbeatDelay = 0.13
    
    // MARK: - Numeric
    
    static let cutoffs: (CGFloat, CGFloat, CGFloat) = (27, 36, 40)
    static let largeCutoffs: (CGFloat, CGFloat) = (100, 189.5)
    
    static let space7: CGFloat = 7
    static let space5: CGFloat = 5
    static let space14: CGFloat = 14
    
    static let baseContentInset: CGFloat = 200
    static let baseNavigationBarHeight: CGFloat = 270
    static let contentInsetNotchAdjustment: CGFloat = 30
    
    static let tappedButtonAlpha: CGFloat = 0.8
    static let tappedAlbumAlpha: CGFloat = 0.2
    
    // MARK: - Strings
    
    static let lyricsTitle = Strings.Lyrics.title
    static let shareText = { (url: String) in Strings.Lyrics.shareText(url) }
    static let likeText = Strings.Lyrics.Button.like
    static let likedText = Strings.Lyrics.Button.liked
    static let fromAlbumText = Strings.Lyrics.Info.fromAlbum
    static let notPartOfAnAlbumText = Strings.Lyrics.Info.notPartOfAnAlbum
    static let producedByText = Strings.Lyrics.Info.producedBy
    
    // MARK: - Alerts
    
    static var notFoundSpotifyAlert: UIAlertController {
        UIAlertController(
            title: Strings.Lyrics.NotFoundSpotify.title,
            message: Strings.Lyrics.NotFoundSpotify.message,
            preferredStyle: .alert
        )
    }
    
    static var notAvailableAlert: UIAlertController {
        UIAlertController(
            title: Strings.Lyrics.NotFoundLyrics.title,
            message: Strings.Lyrics.NotFoundLyrics.message,
            preferredStyle: .alert
        )
    }
    
    // MARK: - Icons
    
    static let filledHeartImage = UIImage(systemName: "heart.fill")!
    static let heartImage = UIImage(systemName: "heart")!
    
    // MARK: - Curves
    
    static let songViewTransformYFunction = { (songViewAdjustment: CGFloat) -> CGFloat in
        (-pow((1 - min((songViewAdjustment) + 0.3, 1)) * (3.68), 3) * 1.3) }
    static let songViewAlphaFunction = { (topPadding: CGFloat) -> CGFloat in
        UIDevice.current.hasNotch ? (0.0479452 * topPadding - 4.4589) : (topPadding / 16.0 - 4) }
    static let infoLabelAlphaFunction = { (topPadding: CGFloat) -> CGFloat in
        (0.028 * topPadding - 4.2) }
    static let buttonsAlphaFunction = { (topPadding: CGFloat) -> CGFloat in
        UIDevice.current.hasNotch ? (0.06 * topPadding - 14.4) : (topPadding / 20 - 10) }
    
}

// MARK: - LyricsViewController

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
    
    @IBOutlet private weak var storyButton: UIButton!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var navigationBarHeightConstraint: NSLayoutConstraint!

    // MARK: - Instance properties

    var viewModel: LyricsViewModel!
    
    var translationInteractor: TranslationAnimationInteractor?
    
    var albumArtThumbnail: UIImage?
    
    var hasAppeared: Bool = false
    
    var isMainScene: Bool = true
    
    var initialLoad: Bool = true
    
    var contextMenuHandler: ImageContextMenuInteractionHandler?
    
    // MARK: - Flows
    
    var flowSafari: DefaultURLAction?
    
    var flowStory: DefaultStringAction?

    var flowFindAlbum: DefaultAlbumStringsAction?

    var flowDismiss: DefaultAction?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupInput()
        setupOutput()
        
        viewModel.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if initialLoad {
            initialLoad = false
        } else {
            viewModel.updateLikeState()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        hasAppeared = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        hasAppeared = false
    }
    
    // MARK: - Helper methods
    
    func generateAttributedAlbumText(highlight: Bool = false) -> NSMutableAttributedString {
        
        let album = viewModel.albumInfo.value
        
        let attrString: NSMutableAttributedString
        
        if let album = album?.0 {
            let text = "\(Constants.fromAlbumText) “\(album)”"
            attrString = NSMutableAttributedString(string: text, attributes: [
                .foregroundColor: highlight ? UIColor.label.withAlphaComponent(Constants.tappedAlbumAlpha) : UIColor.label
            ])
            
            attrString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: 0, length: "\(Constants.fromAlbumText) “".count))
            attrString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: text.count - 1, length: 1))
        } else {
            attrString = NSMutableAttributedString(string: Constants.notPartOfAnAlbumText, attributes: [.foregroundColor: UIColor.secondaryLabel])
        }
        
        return attrString
        
    }
    
}

// MARK: - Setup

extension LyricsViewController {
    
    // MARK: - View
    
    func setupView() {
        
        songLabel.text = viewModel.cleanSongName
        artistLabel.text = viewModel.cleanArtistName
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
            offset: CGSize(width: 0, height: 3),
            opacity: Constants.defaultShadowOpacity,
            viewCornerRadius: 8,
            viewSquircle: true
        )
        
        tableView.contentInset = UIEdgeInsets(top: Constants.baseContentInset - safeAreaInsets.top - (UIDevice.current.hasNotch ? 0 : Constants.contentInsetNotchAdjustment), left: 0, bottom: -safeAreaInsets.bottom, right: 0)
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
        
        [likeButton, shareButton, safariButton, storyButton].forEach {
            $0?.setImage($0?.image(for: .normal)?.withTintColor(.label, renderingMode: .alwaysOriginal), for: .normal)
        }
        
        likeButton.isUserInteractionEnabled = false
        
        if !isMainScene {

            translationInteractor?.pop = true
            
        }
    
    }
    
    // MARK: - Input
    
    func setupInput() {
        
        [likeButton, shareButton, safariButton, storyButton].forEach { button in
            button.reactive.controlEvents([.touchDown, .touchDragEnter]).observeNext { _ in
                UIView.animate(withDuration: Constants.fastAnimationDuration) {
                    button.alpha = 0.5
                }
            }.dispose(in: disposeBag)
        }
        
        [likeButton, shareButton, safariButton, storyButton].forEach { button in
            button.reactive.controlEvents([.touchDragExit, .touchUpInside]).observeNext { [weak self] _ in
                self?.likeButton.layer.removeAllAnimations()
                UIView.animate(withDuration: Constants.fastAnimationDuration) {
                    button.alpha = Constants.tappedButtonAlpha
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
                Haptic.play(Constants.heartbeatTap, delay: Constants.heartbeatDelay)
            }
        }.dispose(in: disposeBag)
        
        shareButton.reactive.tap.throttle(for: Constants.buttonThrottleTime).observeNext { [weak self] _ in
            guard let self = self, let url = self.viewModel.geniusURL else { return }
            Haptic.play(Constants.tinyTap)
            let items = [Constants.shareText(url.absoluteString)]
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
        
        storyButton.reactive.tap.throttle(for: Constants.buttonThrottleTime).observeNext { [weak self] _ in
            guard let self = self,
                  let story = self.viewModel.description.value else { return }
            Haptic.play(Constants.tinyTap)
            self.flowStory?(story)
        }.dispose(in: disposeBag)
        
        firstInfoLabel.reactive.longPressGesture(minimumPressDuration: 0).observeNext { [weak self] recognizer in
            guard let self = self, let fixedAlbumInfo = self.viewModel.fixedAlbumInfo else { return }
            
            if recognizer.state == .ended || recognizer.state == .cancelled {
                UIView.fadeUpdate(self.firstInfoLabel, duration: Constants.buttonTapDuration) { [weak self] in
                    self?.firstInfoLabel.attributedText = self?.generateAttributedAlbumText()
                }
            }
            
            switch recognizer.state {
            case .began:
                UIView.fadeUpdate(self.firstInfoLabel, duration: Constants.buttonTapDuration) { [weak self] in
                    self?.firstInfoLabel.attributedText = self?.generateAttributedAlbumText(highlight: true)
                }
                
            case .ended:
                Haptic.play(Constants.tinyTap)
                self.flowFindAlbum?(fixedAlbumInfo.0, fixedAlbumInfo.1)
                
            default:
                break
            }
        }.dispose(in: disposeBag)
        
    }
    
    // MARK: - Output
    
    func setupOutput() {
        
        viewModel.lyrics.bind(to: tableView, cellType: LyricsSectionCell.self, rowAnimation: .fade) { (cell, item) in
            cell.configure(with: LyricsSectionCellViewModel(section: item))
        }.dispose(in: disposeBag)
        
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
        
        viewModel.albumInfo.dropFirst(1).observeNext { [weak self] _ in
            guard let self = self else { return }
            
            UIView.fadeUpdate(self.firstInfoLabel) {
                self.firstInfoLabel.attributedText = self.generateAttributedAlbumText()
            }
        }.dispose(in: disposeBag)
        
        viewModel.producers.dropFirst(1).observeNext { [weak self] producers in
            guard let self = self, producers.nonEmpty else { return }
            let text = "\(Constants.producedByText) \(producers.joined(separator: " \(Constants.ampersand) "))"
            let attrString = NSMutableAttributedString(string: text, attributes: [.foregroundColor: UIColor.label])
            
            attrString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: 0, length: "\(Constants.producedByText) ".count))
            if producers.count > 1 {
                attrString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: "\(Constants.producedByText) ".count + producers.first.safe.count, length: 3))
            }
            
            UIView.fadeUpdate(self.secondInfoLabel) {
                self.secondInfoLabel.attributedText = attrString
            }
        }.dispose(in: disposeBag)
        
        viewModel.isLoading.dropFirst(1).observeNext { [weak self] isLoading in
            guard let self = self else { return }
            UIView.fadeDisplay(self.activityIndicator, visible: isLoading)
        }.dispose(in: disposeBag)
        
        viewModel.isFailed.observeNext { [weak self] isFailed in
            self?.setNoInternetView(isVisible: isFailed) {
                self?.viewModel.loadData()
            }
        }.dispose(in: disposeBag)
        
        viewModel.isLiked.dropFirst(1).observeNext { [weak self] _ in
            self?.likeButton.isUserInteractionEnabled = true
        }.dispose(in: disposeBag)
        
        viewModel.isLiked.removeDuplicates().observeNext { [weak self] isLiked in
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
        let total: CGFloat = Constants.baseNavigationBarHeight - (UIDevice.current.hasNotch ? 0 : Constants.contentInsetNotchAdjustment)
        let topPadding = min(total, max(Constants.navigationBarHeight + safeAreaInsets.top - Constants.space14, -scrollView.contentOffset.y + Constants.space12) + Constants.space14)
        navigationBarHeightConstraint.constant = topPadding
        tableView.verticalScrollIndicatorInsets.top = topPadding - safeAreaInsets.top - Constants.navigationBarHeight
        
        if scrollView.contentOffset.y >= -Constants.largeCutoffs.0 {
            navigationItem.title = viewModel.cleanCompactSongName.lowercased()
        } else {
            navigationItem.title = Constants.lyricsTitle
        }
        
        buttonsStackView.alpha = pow(topPadding / total, Constants.space20) *
            Constants.buttonsAlphaFunction(topPadding)
        secondInfoLabel.alpha = pow((topPadding + Constants.cutoffs.0) / total, Constants.space16) *
            Constants.infoLabelAlphaFunction(topPadding)
        firstInfoLabel.alpha = pow((topPadding + Constants.cutoffs.0) / total, Constants.space16) *
            Constants.infoLabelAlphaFunction(topPadding)
        songView.alpha = pow((topPadding + Constants.cutoffs.2) / total, Constants.space7) *
            Constants.songViewAlphaFunction(topPadding)
        let songViewAdjustment = pow((topPadding + Constants.cutoffs.1) / total, Constants.space5)
        
        songView.transform = .init(
            translationX: 0,
            y: Constants.songViewTransformYFunction(songViewAdjustment)
        )
    }
    
}
