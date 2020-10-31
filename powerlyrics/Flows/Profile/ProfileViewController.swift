//
//  ProfileViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/31/20.
//

import UIKit

class ProfileViewController: ViewController, ProfileScene {
    
    fileprivate enum Constants {
        static let albumArtShadowOpacity: Float = 0.3
    }
    
    @IBOutlet private weak var tableView: TableView!
    
    @IBOutlet private weak var avatarContainerView: UIView!
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var userInfoStackView: UIStackView!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var navigationBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var avatarDimensionConstraint: NSLayoutConstraint!
    
    var viewModel: ProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupObservers()
    }
    
}

extension ProfileViewController {
    
    func setupView() {
        
        tableView.register(StatsCell.self)
        tableView.register(ActionCell.self)
        tableView.register(BuildCell.self)
        
        tableView.contentInset.top = 250 - safeAreaInsets.top - 20
        
        tableView.delegate = self
        
        avatarImageView.populate(with: nil)
    
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
            .font: FontFamily.RobotoMono.semiBold.font(size: 17)
        ]
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        avatarContainerView.shadow(
            color: .black,
            radius: 6,
            offset: CGSize(width: .zero, height: 3),
            opacity: Constants.albumArtShadowOpacity,
            viewCornerRadius: 52.5
        )
        
    }
    
    func setupObservers() {
        viewModel.items.bind(to: tableView, using: ProfileBinder())
        viewModel.isLoading.map { !$0 }.bind(to: activityIndicator.reactive.isHidden)
    }
    
}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        section == tableView.numberOfSections - 2 ? 10 : 20
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let topPadding = min(250, max(44 + safeAreaInsets.top, -scrollView.contentOffset.y - 20))
        let progress = 125.0 / 79 - topPadding / 158
        tableView.verticalScrollIndicatorInsets.top = topPadding - safeAreaInsets.top - 44
        avatarDimensionConstraint.constant = 105 - 61 * progress
        avatarImageView.layer.cornerRadius = avatarDimensionConstraint.constant / 2
        navigationBarHeightConstraint.constant = topPadding
        // * pow(progress, 4)
        avatarContainerView.transform = .init(translationX: 0, y: -312.831 * pow(progress, 4) + 840.079 * pow(progress, 3) - 793.935 * pow(progress, 2) + 287.687 * progress)
        userInfoStackView.transform = .init(translationX: 0, y: 215.556 * progress - 155.556 * pow(progress, 2))
        
        userInfoStackView.alpha = pow(1 - progress, 8)
        
        avatarContainerView.shadow(
            color: .black,
            radius: 6,
            offset: CGSize(width: .zero, height: 3),
            opacity: Constants.albumArtShadowOpacity,
            viewCornerRadius: avatarDimensionConstraint.constant / 2
        )
    }
    
}
