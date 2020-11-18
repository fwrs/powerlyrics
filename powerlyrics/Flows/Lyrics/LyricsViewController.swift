//
//  LyricsViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/3/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Haptica
import SafariServices
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
            Haptic.play(".")
            flowDismiss?()
        }.dispose(in: disposeBag)
        
        navigationItem.rightBarButtonItem?.reactive.tap.observeNext { [self] _ in
            if let url = viewModel.spotifyURL.value ?? viewModel.song.spotifyURL {
                Haptic.play(".")
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                present(UIAlertController(title: "Not found", message: "We couldn’t find this item on Spotify.", preferredStyle: .alert).with {
                    $0.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                }, animated: true, completion: nil)
            }
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
        
        tableView.contentInset = UIEdgeInsets(top: 200 - safeAreaInsets.top - (UIDevice.current.hasNotch ? 0 : 30), left: .zero, bottom: -safeAreaInsets.bottom, right: .zero)
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
        viewModel.lyricsNotFound.observeNext { [self] isNotFound in
            if isNotFound {
                present(UIAlertController(title: "Lyrics not available", message: "This song isn’t stored in the Genius database.", preferredStyle: .alert).with {
                    $0.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        flowDismiss?()
                    }))
                }, animated: true, completion: nil)
            }
        }.dispose(in: disposeBag)
        
        viewModel.album.dropFirst(1).observeNext { [self] album in
            let text = "From album “\(album)”"
            let attrString = NSMutableAttributedString(string: text, attributes: [.foregroundColor: UIColor.label])
            
            attrString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: 0, length: "From album “".count))
            attrString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: text.count - 1, length: 1))
            
            UIView.transition(with: firstInfoLabel, duration: 0.3, options: .transitionCrossDissolve) {
                firstInfoLabel.attributedText = attrString
                firstInfoLabel.isHidden = false
            }
        }.dispose(in: disposeBag)
        
        viewModel.producers.dropFirst(1).observeNext { [self] producers in
            guard producers.nonEmpty else { return }
            let text = "Produced by \(producers.joined(separator: " & "))"
            let attrString = NSMutableAttributedString(string: text, attributes: [.foregroundColor: UIColor.label])
            
            attrString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: 0, length: "Produced by ".count))
            if producers.count > 1 {
                attrString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: "Produced by ".count + producers.first.safe.count, length: 3))
            }
            
            UIView.transition(with: secondInfoLabel, duration: 0.3, options: .transitionCrossDissolve) {
                secondInfoLabel.attributedText = attrString
            }
        }.dispose(in: disposeBag)
        
        viewModel.lyrics.bind(to: tableView, cellType: LyricsSectionCell.self, rowAnimation: .fade) { (cell, item) in
            cell.configure(with: LyricsSectionCellViewModel(section: item))
        }.dispose(in: disposeBag)
        
        viewModel.isLoading.observeNext { [self] loading in
            UIView.animate(withDuration: 0.35) {
                activityIndicator.alpha = loading ? 1 : 0
            }
        }.dispose(in: disposeBag)
        
        viewModel.isFailed.observeNext { [self] failed in
            setNoInternetView(isVisible: failed) {
                viewModel.loadData()
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
                    button.alpha = 0.8
                }
            }.dispose(in: disposeBag)
        }
        
        likeButton.reactive.tap.throttle(for: 0.3).observeNext { [self] _ in
            guard viewModel.genre.value != nil else { return }
            if viewModel.isLiked.value {
                viewModel.unlikeSong()
                Haptic.play(".")
            } else {
                viewModel.likeSong()
                Haptic.play(".-o--.-O", delay: 0.2)
            }
        }.dispose(in: disposeBag)
        
        shareButton.reactive.tap.throttle(for: 0.3).observeNext { [self] _ in
            guard let url = viewModel.geniusURL else { return }
            Haptic.play(".")
            let items = ["Just discovered this awesome song using powerlyrics app: \(url.absoluteURL)"]
            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            present(activityViewController, animated: true)
        }.dispose(in: disposeBag)
        
        safariButton.reactive.tap.throttle(for: 0.3).observeNext { [self] _ in
            guard let url = viewModel.geniusURL else { return }
            Haptic.play(".")
            let safariViewController = SFSafariViewController(url: url, configuration: SFSafariViewController.Configuration())
            safariViewController.preferredControlTintColor = .tintColor
            present(safariViewController, animated: true)
        }.dispose(in: disposeBag)
        
        notesButton.reactive.tap.throttle(for: 0.3).observeNext { [self] _ in
            guard let description = viewModel.description.value?.typographized else { return }
            Haptic.play(".")
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.left
            paragraphStyle.lineSpacing = 0.5
            
            let attributedMessageText = NSMutableAttributedString(
                string: description,
                attributes: [
                    NSAttributedString.Key.paragraphStyle: paragraphStyle,
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)
                ]
            )
            
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.alignment = NSTextAlignment.center
            
            let attributedTitleText = NSMutableAttributedString(
                string: "Story",
                attributes: [
                    NSAttributedString.Key.paragraphStyle: titleParagraphStyle,
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0, weight: .medium)
                ]
            )
            
            present(UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet).with {
                $0.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                $0.setValue(attributedMessageText, forKey: "attributedMessage")
                $0.setValue(attributedTitleText, forKey: "attributedTitle")
            }, animated: true, completion: nil)
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
        
        let controller = ImagePreviewController(viewModel.song.albumArt, placeholder: albumArtThumbnail)
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
                        window.topViewController?.present(UIActivityViewController(activityItems: [image], applicationActivities: nil), animated: true, completion: nil)
                    }
                }])
            }
        )
    }
    
    @objc private func image(image: UIImage!, didFinishSavingWithError error: NSError!, contextInfo: AnyObject!) {
        if error != nil {
            window.topViewController?.present(UIAlertController(title: "Failed to save image", message: "Please check application permissions and try again.", preferredStyle: .alert).with { $0.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))}, animated: true, completion: nil)
        } else {
            Haptic.play(".-O")
            window.topViewController?.present(UIAlertController(title: "Image saved successfuly", message: "Check your gallery to find it.", preferredStyle: .alert).with { $0.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))}, animated: true, completion: nil)
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        UIView.animate(withDuration: 0.2, delay: 0.3) { [self] in
            albumArtContainerView.layer.shadowOpacity = Constants.albumArtShadowOpacity
        }
    }
    
}

extension LyricsViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let total: CGFloat = 270.0 - (UIDevice.current.hasNotch ? 0.0 : 30.0)
        let topPadding = min(total, max(44 + safeAreaInsets.top - 14, -scrollView.contentOffset.y + 12) + 14)
        navigationBarHeightConstraint.constant = topPadding
        tableView.verticalScrollIndicatorInsets.top = topPadding - safeAreaInsets.top - 44
        if scrollView.contentOffset.y >= -100 {
            navigationItem.title = songLabel.text.safe.lowercased()
        } else {
            navigationItem.title = "lyrics"
        }
        buttonsStackView.alpha = pow(topPadding / total, 20)
        secondInfoLabel.alpha = pow((topPadding + 27) / total, 20)
        firstInfoLabel.alpha = pow((topPadding + 38) / total, 20)
        songView.alpha = pow((topPadding + 40) / total, 7)
        let songViewAdjustment = pow((topPadding + 36) / total, 5)
        songView.transform = .init(translationX: 0, y: -pow((1 - min((songViewAdjustment) + 0.3, 1)) * (3.68), 3) * 1.3)
    }
    
}
