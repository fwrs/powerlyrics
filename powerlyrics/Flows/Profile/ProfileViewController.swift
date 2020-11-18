//
//  ProfileViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/31/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Haptica
import SafariServices
import UIKit

class ProfileViewController: ViewController, ProfileScene {
    
    fileprivate enum Constants {
        static let albumArtShadowOpacity: Float = 0.3
    }
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: TableView!
    
    @IBOutlet private weak var avatarContainerView: UIView!
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    
    @IBOutlet private weak var userInfoStackView: UIStackView!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var navigationBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var navigationBarView: UIVisualEffectView!
    
    @IBOutlet private weak var avatarDimensionConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var userNameLabel: UILabel!
    
    @IBOutlet private weak var premiumIconImageView: UIImageView!
    
    @IBOutlet private weak var registerDateLabel: UILabel!
    
    // MARK: - Instance properties
    
    var viewModel: ProfileViewModel!
    
    override var prefersNavigationBarHidden: Bool { true }
    
    var started = true
    
    var initial = true
    
    // MARK: - Flows
    
    var flowLikedSongs: DefaultAction?
    
    var flowSetup: DefaultSetupModeAction?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupObservers()
        viewModel.updateData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if initial {
            initial = false
            return
        }
        viewModel.updateData()
    }
    
}

extension ProfileViewController {
    
    func setupView() {
        
        tableView.register(StatsCell.self)
        tableView.register(ActionCell.self)
        tableView.register(BuildCell.self)
        
        tableView.contentInset.top = 250 - safeAreaInsets.top + 22 - (UIDevice.current.hasNotch ? 0 : 24)
        
        tableView.delegate = self
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
            .font: FontFamily.RobotoMono.semiBold.font(size: 17)
        ]
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        if !UIDevice.current.hasNotch {
            userInfoStackView.spacing = 2
        }
        
        let interaction = UIContextMenuInteraction(delegate: self)
        avatarImageView.addInteraction(interaction)
    }
    
    func setupObservers() {
        viewModel.items.bind(to: tableView, using: ProfileBinder())
        viewModel.isLoading.map(\.negated).bind(to: activityIndicator.reactive.isHidden)
        
        tableView.reactive.selectedRowIndexPath.observeNext { [self] indexPath in
            let item = viewModel.items[itemAt: indexPath]
            
            if case .action(let actionCellViewModel) = item {
                Haptic.play(".")
                if actionCellViewModel.action == .likedSongs {
                    flowLikedSongs?()
                } else if actionCellViewModel.action == .signOut {
                    present(UIAlertController(title: "Are you sure you want to sign out?", message: "This will delete all local data, including liked songs, but not Spotify data. There’s no undoing this.", preferredStyle: .alert).with {
                        $0.addAction(UIAlertAction(title: "Reset and sign out", style: .destructive, handler: { _ in
                            viewModel.spotifyProvider.logout()
                            viewModel.updateData()
                            if let homeViewController = ((window.rootViewController as? UITabBarController)?.viewControllers?.first as? Router)?.viewControllers.first as? HomeViewController {
                                homeViewController.viewModel.checkSpotifyAccount()
                            }
                            if let searchViewController = ((window.rootViewController as? UITabBarController)?.viewControllers?[safe: 1] as? Router)?.viewControllers.first as? SearchViewController {
                                searchViewController.viewModel.reset()
                            }
                            if let genreMapViewController = ((window.rootViewController as? UITabBarController)?.viewControllers?[safe: 2] as? Router)?.viewControllers.first as? GenreMapViewController {
                                genreMapViewController.reset()
                            }
                            for router in ((window.rootViewController as? UITabBarController)?.viewControllers) ?? [] {
                                (router as? Router)?.popToRootViewController(animated: true)
                            }
                            flowSetup?(.initial)
                        }))
                        $0.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
                    }, animated: true, completion: nil)
                } else if actionCellViewModel.action == .manageAccount {
                    let url = URL(string: "https://www.spotify.com/account/overview/")!
                    let safariViewController = SFSafariViewController(url: url, configuration: SFSafariViewController.Configuration())
                    safariViewController.preferredControlTintColor = .tintColor
                    present(safariViewController, animated: true)
                } else if actionCellViewModel.action == .appSourceCode {
                    let url = URL(string: "https://www.github.com/fwrs/powerlyrics")!
                    let safariViewController = SFSafariViewController(url: url, configuration: SFSafariViewController.Configuration())
                    safariViewController.preferredControlTintColor = .tintColor
                    present(safariViewController, animated: true)
                } else if actionCellViewModel.action == .connectToSpotify {
                    flowSetup?(.manual)
                }
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        }.dispose(in: disposeBag)
        
        viewModel.name.bind(to: userNameLabel.reactive.text).dispose(in: disposeBag)
        viewModel.premium.map(\.negated).bind(to: premiumIconImageView.reactive.isHidden).dispose(in: disposeBag)
        viewModel.avatar.observeNext { [self] image in
            avatarImageView.populate(with: image)
        }.dispose(in: disposeBag)
        viewModel.registerDate.compactMap { $0 }.map { DateFormatter().with { $0.dateFormat = "d MMM yyyy" }.string(for: $0) }.map { "Registered \($0.safe)" }.bind(to: registerDateLabel.reactive.text).dispose(in: disposeBag)
        viewModel.registerDate.filter { $0 == nil }.map { _ in "Unknown register date" }.bind(to: registerDateLabel.reactive.text).dispose(in: disposeBag)
    }
    
}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        section == tableView.numberOfSections - 2 ? 10 : (UIDevice.current.hasNotch ? 20 : 16)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let total: CGFloat = 250 - (UIDevice.current.hasNotch ? 0 : 20)
        let topPadding = min(total, max(44 + safeAreaInsets.top, -scrollView.contentOffset.y - 22 + (UIDevice.current.hasNotch ? 0 : 4)))
        let progress = UIDevice.current.hasNotch ? (125.0 / 79 - topPadding / 158) : (115.0 / 83 - topPadding / 166)
        tableView.verticalScrollIndicatorInsets.top = topPadding - safeAreaInsets.top
        avatarDimensionConstraint.constant = (105 - 61 * progress) * (UIDevice.current.hasNotch ? 1 : 0.9)
        avatarImageView.layer.cornerRadius = avatarDimensionConstraint.constant / 2
        navigationBarHeightConstraint.constant = topPadding
        let scale = min(1 - progress + (UIDevice.current.hasNotch ? 0.8 : 0.77), 1)
        let translateMultiplier: CGFloat = UIDevice.current.hasNotch ? 1 : 0.55
        let translationY: CGFloat = ((-312.831 * pow(progress, 4) + 840.079 * pow(progress, 3) - 793.935 * pow(progress, 2) + 287.687 * progress) * translateMultiplier) + (UIDevice.current.hasNotch ? 0 : (7 * progress - 7))
        avatarContainerView.transform = CGAffineTransform(translationX: 0, y: translationY).scaledBy(x: scale, y: scale)
        userInfoStackView.transform = .init(translationX: 0, y: (215.556 * progress - 155.556 * pow(progress, 2)) - (UIDevice.current.hasNotch ? 0 : 9))
        
        userInfoStackView.alpha = pow(1 - progress, 8)
        
        delay(started ? 0.01 : 0) { [self] in
            avatarContainerView.shadow(
                color: .black,
                radius: 6,
                offset: CGSize(width: .zero, height: 3),
                opacity: Constants.albumArtShadowOpacity,
                viewCornerRadius: avatarDimensionConstraint.constant / 2
            )
        }
        started = false
    }
    
}

extension ProfileViewController: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard avatarImageView.loaded else { return nil }
        UIView.animate(withDuration: 0.2, delay: 0.5) { [self] in
            avatarContainerView.layer.shadowOpacity = 0
        }
    
        let controller = ImagePreviewController(viewModel.fullAvatar.value, placeholder: avatarImageView.image)
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
            avatarContainerView.layer.shadowOpacity = Constants.albumArtShadowOpacity
        }
    }
    
}
