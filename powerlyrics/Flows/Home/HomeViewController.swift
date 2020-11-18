//
//  HomeView.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import Haptica
import ReactiveKit
import SafariServices
import UIKit

// MARK: - HomeViewController

class HomeViewController: ViewController, HomeScene {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: TableView!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Instance properties
    
    var viewModel: HomeViewModel!
    
    var lastSelectedIndexPath: IndexPath?
    
    var initialLoad = true
    
    // MARK: - Flows
    
    var flowLyrics: DefaultSharedSongPreviewAction?
    
    var flowSetup: DefaultSetupModeAction?
    
    var flowTrends: DefaultSharedSongListAction?
    
    var flowVirals: DefaultSharedSongListAction?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupInput()
        setupOutput()
        
        if viewModel.shouldSignUp {
            flowSetup?(.initial)
        } else {
            viewModel.loadData()
            viewModel.checkSpotifyAccount()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !initialLoad {
            viewModel.checkSpotifyAccount()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !initialLoad {
            viewModel.updateState()
        }
        
        initialLoad = false
    }
    
}

// MARK: - Setup

extension HomeViewController {
    
    // MARK: - View
    
    func setupView() {
        tableView.register(SongCell.self)
        tableView.register(ActionCell.self)
    }
    
    // MARK: - Input
    
    func setupInput() {
        
        tableView.reactive.selectedRowIndexPath.observeNext { [self] indexPath in
            lastSelectedIndexPath = indexPath
            tableView.deselectRow(at: indexPath, animated: true)
            Haptic.play(Constants.tinyTap)
            let cell = viewModel.items[itemAt: indexPath]
            if case .song(let viewModel) = cell {
                flowLyrics?(viewModel.song, (tableView.cellForRow(at: indexPath) as? SongCell)?.currentImage)
            } else if case .action(let actionCellViewModel) = cell {
                if actionCellViewModel.action == .seeTrendingSongs {
                    flowTrends?(Array(viewModel.trendingSongs.prefix(3)))
                } else if actionCellViewModel.action == .seeViralSongs {
                    flowVirals?(Array(viewModel.viralSongs.prefix(3)))
                }
            }
        }.dispose(in: disposeBag)
        
        navigationItem.rightBarButtonItem?.reactive.tap.throttle(for: 0.5).observeNext { [self] _ in
            Haptic.play(Constants.tinyTap)
            if viewModel.isSpotifyAccount.value {
                let url = URL(string: "https://www.spotify.com/account/overview/")!
                let safariViewController = SFSafariViewController(url: url, configuration: SFSafariViewController.Configuration())
                safariViewController.preferredControlTintColor = .tintColor
                present(safariViewController, animated: true)
            } else {
                flowSetup?(.manual)
            }
        }.dispose(in: disposeBag)
        
    }
    
    // MARK: - Output
    
    func setupOutput() {
        viewModel.items.bind(to: tableView, using: HomeBinder())
        
        viewModel.isSpotifyAccount.observeNext { [self] isSpotifyAccount in
            navigationItem.rightBarButtonItem?.image = isSpotifyAccount ?
                UIImage(systemName: "gear") :
                UIImage(systemName: "person.crop.circle.badge.plus")
        }.dispose(in: disposeBag)
        
        viewModel.isError.observeNext { [self] isError in
            setNoInternetView(isVisible: isError) {
                viewModel.loadData()
            }
        }.dispose(in: disposeBag)
        
        viewModel.isRefreshing.observeNext { [self] isRefreshing in
            tableView.isRefreshing = isRefreshing
        }.dispose(in: disposeBag)
        
        viewModel.isLoading.observeNext { [self] loading in
            activityIndicator.fadeDisplay(visible: loading)
            
            if loading {
                tableView.unsetRefreshControl()
            } else {
                tableView.setRefreshControl { [self] in
                    viewModel.loadData(refresh: true)
                }
                scrollToTop()
            }
        }.dispose(in: disposeBag)
    }
    
}

// MARK: - TranslationAnimationView

extension HomeViewController: TranslationAnimationView {
    
    var translationViews: [UIView] {
        guard let indexPath = lastSelectedIndexPath,
              let container = (tableView.cellForRow(at: indexPath) as? SongCell)?.songContainer else { return [] }
        return [container]
    }
    
}
