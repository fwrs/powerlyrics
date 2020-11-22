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

// MARK: - Constants

fileprivate extension Constants {
    
    // MARK: - Text
    
    static let registerDateFormat = "d MMM yyyy"
    static let unknownRegisterDateText = Strings.Profile.unknownRegisterDate
    static let unknownUserText = Strings.Profile.unknownUser
    static let registeredText = { (date: String) in Strings.Profile.registered(date) }
    static let confirmLogOutActionTitle = Strings.Profile.LogOut.accept
    static let githubURL = URL(string: "https://www.github.com/fwrs/powerlyrics")!
    
    // MARK: - Numeric
    
    static let tinyDelay: TimeInterval = 0.01
    static let defaultTopPadding: CGFloat = 250
    
    // MARK: - Alerts
    
    static let cancelLogOutAction = UIAlertAction(title: Constants.cancel, style: .cancel, handler: nil )

    static var logOutAlert: UIAlertController {
        UIAlertController(
            title: Strings.Profile.LogOut.title,
            message: Strings.Profile.LogOut.message,
            preferredStyle: .alert
        )
    }
    
    // MARK: - Curves
    
    static let topPaddingFunction = { (x: CGFloat, safeAreaInsets: UIEdgeInsets) -> CGFloat in
        min(
            Constants.defaultTopPadding - (UIDevice.current.hasNotch ? .zero : Constants.space20),
            max(44 + safeAreaInsets.top, -x - 22 + (UIDevice.current.hasNotch ? 0 : 4))
        )
    }
    
    static let progressFunction = { (x: CGFloat) -> CGFloat in
        if UIDevice.current.hasNotch {
            return 125.0 / 79 - x / 158
        } else {
            return 115.0 / 83 - x / 166
        }
    }
    
    static let translationYAvatarFunction = { (x: CGFloat) -> CGFloat in
        ((-312.831 * pow(x, 4) + 840.079 * pow(x, 3) - 793.935 * pow(x, 2) + 287.687 * x) *
            (UIDevice.current.hasNotch ? 1 : 0.55)) + (UIDevice.current.hasNotch ? .zero : (7 * x - 7)) }
    static let translationYUserInfoFunction = { (x: CGFloat) -> CGFloat in
        (215.556 * x - 155.556 * pow(x, 2)) - (UIDevice.current.hasNotch ? .zero : 9) }
    static let avatarHeightFunction = { (x: CGFloat) -> CGFloat in
        (105 - 61 * x) * (UIDevice.current.hasNotch ? 1 : 0.9) }
    static let avatarScaleFunction = { (x: CGFloat) -> CGFloat in
        min(1 - x + (UIDevice.current.hasNotch ? 0.8 : 0.77), 1) }
    
}

// MARK: - ProfileViewController

class ProfileViewController: ViewController, ProfileScene {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: TableView!
    
    @IBOutlet private weak var avatarContainerView: UIView!
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    
    @IBOutlet private weak var userInfoStackView: UIStackView!
    
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
        
        _ = NotificationCenter.default.addObserver(
            forName: .appDidLogin,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.viewModel.loadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.loadData()
    }
    
    // MARK: - Helper methods
    
    func presentSignOutAlert() {
        
        present(Constants.logOutAlert.with {
            $0.addAction(UIAlertAction(title: Constants.confirmLogOutActionTitle, style: .destructive) { [weak self] _ in
                self?.viewModel.logout()
            })
            $0.addAction(Constants.cancelLogOutAction)
        }, animated: true, completion: nil)
        
    }
    
}

// MARK: - Setup

extension ProfileViewController {
    
    // MARK: - View
    
    func setupView() {
        
        tableView.register(ProfileStatsCell.self)
        tableView.register(ActionCell.self)
        tableView.register(ProfileBuildCell.self)
        
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
        
        tableView.reactive.selectedRowIndexPath.observeNext { [weak self] indexPath in
            guard let self = self else { return }
            
            let item = self.viewModel.items[itemAt: indexPath]
            
            if case .action(let actionCellViewModel) = item {
                Haptic.play(Constants.tinyTap)
                
                switch actionCellViewModel.action {
                case .likedSongs:
                    self.flowLikedSongs?()
                    
                case .manageAccount:
                    self.flowSafari?(Constants.accountManagementURL)
                    
                case .appSourceCode:
                    self.flowSafari?(Constants.githubURL)
                    
                case .connectToSpotify:
                    self.flowSetup?(.manual)
                    
                case .signOut:
                    self.presentSignOutAlert()
                    
                default:
                    break
                }
            }
            
            self.tableView.deselectRow(at: indexPath, animated: true)
        }.dispose(in: disposeBag)
        
    }
    
    // MARK: - Output
    
    func setupOutput() {
        
        viewModel.items.bind(to: tableView, using: ProfileBinder()).dispose(in: disposeBag)
        
        viewModel.avatarPreviewable.bind(to: avatarImageView.reactive.isUserInteractionEnabled).dispose(in: disposeBag)
        
        viewModel.name.map { $0 ?? Constants.unknownUserText }.bind(to: userNameLabel.reactive.text).dispose(in: disposeBag)
        viewModel.premium.map(\.negated).bind(to: premiumIconImageView.reactive.isHidden).dispose(in: disposeBag)
        viewModel.avatar.observeNext { [weak self] image in
            self?.avatarImageView.populate(with: image)
        }.dispose(in: disposeBag)
        
        viewModel.registerDate
            .compactMap { $0 }
            .map { DateFormatter().with { $0.dateFormat = Constants.registerDateFormat }.string(for: $0) }
            .map { Constants.registeredText($0.safe) }
            .bind(to: registerDateLabel.reactive.text)
            .dispose(in: disposeBag)
        
        viewModel.registerDate
            .filter { $0 == nil }
            .map { _ in Constants.unknownRegisterDateText }
            .bind(to: registerDateLabel.reactive.text)
            .dispose(in: disposeBag)
        
        viewModel.fullAvatar.observeNext { [weak self] image in
            self?.contextMenuHandler?.updateFullImage(with: image)
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
            Constants.space12 :
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
        
        delay(shouldDrawShadow ? Constants.tinyDelay : .zero) { [weak self] in
            guard let self = self else { return }
            self.avatarContainerView.shadow(
                color: Constants.albumArtShadowColor,
                radius: Constants.albumArtShadowRadius,
                offset: Constants.albumArtShadowOffset,
                opacity: Constants.defaultShadowOpacity,
                viewCornerRadius: self.avatarDimensionConstraint.constant / .two
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
            case .stats(let profileStatsCellViewModel):
                let cell = tableView.dequeue(ProfileStatsCell.self, indexPath: indexPath)
                cell.configure(with: profileStatsCellViewModel)
                cell.selectionStyle = .none
                cell.isUserInteractionEnabled = false
                return cell
                
            case .action(let actionCellViewModel):
                let cell = tableView.dequeue(ActionCell.self, indexPath: indexPath)
                cell.configure(with: actionCellViewModel)
                return cell
                
            case .build(let profileBuildCellViewModel):
                let cell = tableView.dequeue(ProfileBuildCell.self, indexPath: indexPath)
                cell.configure(with: profileBuildCellViewModel)
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
