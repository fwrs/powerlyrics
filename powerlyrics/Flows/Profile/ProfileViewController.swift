//
//  ProfileViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/31/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import Haptica
import ReactiveKit
import UIKit

// MARK: - Constants

fileprivate extension Constants {
    
    static let registerDateFormat = "d MMM yyyy"

    static let unknownRegisterDateText = "Unknown register date"
    
    static let registeredText = "Registered"
    
    static let confirmLogOutActionTitle = "Reset and sign out"
    
    static let cancelLogOutAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil )
    
    static let logOutAlert = UIAlertController(
        title: "Are you sure you want to sign out?",
        message: "This will delete all local data, including liked songs, but not Spotify data. There’s no undoing this.",
        preferredStyle: .alert
    )
    
    static let githubURL = URL(string: "https://www.github.com/fwrs/powerlyrics")!
    
    static let tinyDelay: TimeInterval = 0.01
    
    static let defaultTopPadding: CGFloat = 250
    
    static let topPaddingFunction = { (contentOffset: CGFloat, safeAreaInsets: UIEdgeInsets) -> CGFloat in
        min(
            Constants.defaultTopPadding - (UIDevice.current.hasNotch ? .zero : Constants.space20),
            max(44 + safeAreaInsets.top, -contentOffset - 22 + (UIDevice.current.hasNotch ? 0 : 4))
        )
    }
    
    static let progressFunction = { (topPadding: CGFloat) -> CGFloat in
        if UIDevice.current.hasNotch {
            return 125.0 / 79 - topPadding / 158
        } else {
            return 115.0 / 83 - topPadding / 166
        }
    }
    
    static let translationYAvatarFunction = { (progress: CGFloat) -> CGFloat in ((-312.831 * pow(progress, 4) + 840.079 * pow(progress, 3) - 793.935 * pow(progress, 2) + 287.687 * progress) * (UIDevice.current.hasNotch ? 1 : 0.55)) + (UIDevice.current.hasNotch ? 0 : (7 * progress - 7)) }
    
    static let translationYUserInfoFunction = { (progress: CGFloat) -> CGFloat in (215.556 * progress - 155.556 * pow(progress, 2)) - (UIDevice.current.hasNotch ? 0 : 9) }
    
    static let avatarHeightFunction = { (progress: CGFloat) -> CGFloat in (105 - 61 * progress) * (UIDevice.current.hasNotch ? 1 : 0.9) }
    
    static let avatarScaleFunction = { (progress: CGFloat) -> CGFloat in min(1 - progress + (UIDevice.current.hasNotch ? 0.8 : 0.77), 1) }
    
}

// MARK: - ProfileViewController

class ProfileViewController: ViewController, ProfileScene {
    
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
    
    override var prefersNavigationBarHidden: Bool { true }
    
    var viewModel: ProfileViewModel!

    var contextMenuHandler: ImageContextMenuInteractionHandler?

    var shouldDrawShadow = true
    
    var initialLoad = true
    
    // MARK: - Flows
    
    var flowSafari: DefaultURLAction?
    
    var flowLikedSongs: DefaultAction?
    
    var flowSetup: DefaultSetupModeAction?
    
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
        
        if initialLoad {
            initialLoad = false
            return
        }
        
        viewModel.loadData()
    }
    
    // MARK: - Helper methods
    
    func presentSignOutAlert() {
        
        present(Constants.logOutAlert.with {
            $0.addAction(UIAlertAction(title: Constants.confirmLogOutActionTitle, style: .destructive) { [self] _ in
                viewModel.spotifyProvider.logout()
                viewModel.loadData()
                viewModel.resetAllViewControllers(window: window)
                flowSetup?(.initial)
            })
            $0.addAction(Constants.cancelLogOutAction)
        }, animated: true, completion: nil)
        
    }
    
}

// MARK: - Setup

extension ProfileViewController {
    
    // MARK: - View
    
    func setupView() {
        
        tableView.register(StatsCell.self)
        tableView.register(ActionCell.self)
        tableView.register(BuildCell.self)
        
        tableView.contentInset.top = Constants.defaultTopPadding - safeAreaInsets.top +
            Constants.space20 + .two - (UIDevice.current.hasNotch ? .zero : Constants.space24)
        
        tableView.delegate = self
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        if !UIDevice.current.hasNotch {
            userInfoStackView.spacing = Constants.space2
        }
        
        let contextMenuHandler = ImageContextMenuInteractionHandler(
            shadowFadeView: avatarContainerView,
            imageView: avatarImageView
        )
        self.contextMenuHandler = contextMenuHandler
        let interaction = UIContextMenuInteraction(delegate: contextMenuHandler)
        avatarImageView.addInteraction(interaction)
        
    }
    
    // MARK: - Input
    
    func setupInput() {
        
        tableView.reactive.selectedRowIndexPath.observeNext { [self] indexPath in
            let item = viewModel.items[itemAt: indexPath]
            
            if case .action(let actionCellViewModel) = item {
                Haptic.play(Constants.tinyTap)
                
                switch actionCellViewModel.action {
                case .likedSongs:
                    flowLikedSongs?()
                case .manageAccount:
                    flowSafari?(Constants.accountManagementURL)
                case .appSourceCode:
                    flowSafari?(Constants.githubURL)
                case .connectToSpotify:
                    flowSetup?(.manual)
                case .signOut:
                    presentSignOutAlert()
                default:
                    break
                }
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        }.dispose(in: disposeBag)
        
    }
    
    // MARK: - Output
    
    func setupOutput() {
        viewModel.items.bind(to: tableView, using: ProfileBinder())
        viewModel.isLoading.map(\.negated).bind(to: activityIndicator.reactive.isHidden)
        
        viewModel.name.bind(to: userNameLabel.reactive.text).dispose(in: disposeBag)
        viewModel.premium.map(\.negated).bind(to: premiumIconImageView.reactive.isHidden).dispose(in: disposeBag)
        viewModel.avatar.observeNext { [self] image in
            avatarImageView.populate(with: image)
        }.dispose(in: disposeBag)
        
        viewModel.registerDate
            .compactMap { $0 }
            .map { DateFormatter().with { $0.dateFormat = Constants.registerDateFormat }.string(for: $0) }
            .map { "\(Constants.registeredText) \($0.safe)" }
            .bind(to: registerDateLabel.reactive.text)
            .dispose(in: disposeBag)
        
        viewModel.registerDate
            .filter { $0 == nil }
            .map { _ in Constants.unknownRegisterDateText }
            .bind(to: registerDateLabel.reactive.text)
            .dispose(in: disposeBag)
        
        viewModel.avatar.observeNext { [self] image in
            contextMenuHandler?.updateFullImage(with: image)
        }.dispose(in: disposeBag)
    }
    
}

// MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        section == tableView.numberOfSections - .two ?
            Constants.space10 :
            (UIDevice.current.hasNotch ? Constants.space20 : Constants.space16)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let topPadding: CGFloat = Constants.topPaddingFunction(scrollView.contentOffset.y, safeAreaInsets)
        let progress: CGFloat = Constants.progressFunction(topPadding)
        let scale: CGFloat = Constants.avatarScaleFunction(progress)
        
        tableView.verticalScrollIndicatorInsets.top = topPadding - safeAreaInsets.top
        avatarDimensionConstraint.constant = Constants.avatarHeightFunction(progress)
        avatarImageView.layer.cornerRadius = avatarDimensionConstraint.constant / .two
        navigationBarHeightConstraint.constant = topPadding
        
        avatarContainerView.transform = CGAffineTransform(
            translationX: .zero,
            y: Constants.translationYAvatarFunction(progress)
        ).scaledBy(x: scale, y: scale)
        
        userInfoStackView.transform = .init(
            translationX: .zero,
            y: Constants.translationYUserInfoFunction(progress)
        )
        
        userInfoStackView.alpha = pow(.one - progress, Constants.space8)
        
        delay(shouldDrawShadow ? Constants.tinyDelay : .zero) { [self] in
            avatarContainerView.shadow(
                color: Constants.albumArtShadowColor,
                radius: Constants.albumArtShadowRadius,
                offset: Constants.albumArtShadowOffset,
                opacity: Constants.defaultShadowOpacity,
                viewCornerRadius: avatarDimensionConstraint.constant / .two
            )
        }
        
        shouldDrawShadow = false
    }
    
}

// MARK: - ProfileBinder

class ProfileBinder<Changeset: SectionedDataSourceChangeset>: TableViewBinderDataSource<Changeset> where Changeset.Collection == Array2D<(), ProfileCell> {

    override init() {
        super.init { (items, indexPath, uiTableView) in
            let element = items[childAt: indexPath]
            let tableView = uiTableView as! TableView
            switch element.item {
            case .stats(let statsCellViewModel):
                let cell = tableView.dequeue(StatsCell.self, indexPath: indexPath)
                cell.configure(with: statsCellViewModel)
                cell.selectionStyle = .none
                cell.isUserInteractionEnabled = false
                return cell
            case .action(let actionCellViewModel):
                let cell = tableView.dequeue(ActionCell.self, indexPath: indexPath)
                cell.configure(with: actionCellViewModel)
                return cell
            case .build(let buildCellViewModel):
                let cell = tableView.dequeue(BuildCell.self, indexPath: indexPath)
                cell.configure(with: buildCellViewModel)
                cell.selectionStyle = .none
                cell.isUserInteractionEnabled = false
                return cell
            default:
                fatalError("Invalid cell")
            }
        }
        
        rowReloadAnimation = .fade
        rowInsertionAnimation = .none
        rowDeletionAnimation = .none
    }

}
