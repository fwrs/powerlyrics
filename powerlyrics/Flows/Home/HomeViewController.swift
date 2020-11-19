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
import UIKit

// MARK: - Constants

extension Constants {
    
    static let accountManagementURL = URL(string: "https://www.spotify.com/account/overview/")!
    
    static let maxPlaylistPreviewCount = 3
    
}

fileprivate extension Constants {
    
    static let personCheckIcon = UIImage(systemName: "person.crop.circle.badge.checkmark")
    
    static let personPlusIcon = UIImage(systemName: "person.crop.circle.badge.plus")
    
}

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
    
    var flowSafari: DefaultURLAction?
    
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
                    flowTrends?(Array(viewModel.trendingSongs.prefix(Constants.maxPlaylistPreviewCount)))
                } else if actionCellViewModel.action == .seeViralSongs {
                    flowVirals?(Array(viewModel.viralSongs.prefix(Constants.maxPlaylistPreviewCount)))
                }
            }
        }.dispose(in: disposeBag)
        
        navigationItem.rightBarButtonItem?.reactive.tap.throttle(for: Constants.buttonThrottleTime).observeNext { [self] _ in
            Haptic.play(Constants.tinyTap)
            if viewModel.isSpotifyAccount.value {
                flowSafari?(Constants.accountManagementURL)
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
                Constants.personCheckIcon :
                Constants.personPlusIcon
        }.dispose(in: disposeBag)
        
        viewModel.isFailed.observeNext { [self] isFailed in
            setNoInternetView(isVisible: isFailed) {
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
              let container = (tableView.cellForRow(at: indexPath) as? SongCell)?
                .songContainer else { return [] }
        return [container]
    }
    
}

// MARK: - HomeBinder

class HomeBinder<Changeset: SectionedDataSourceChangeset>: TableViewBinderDataSource<Changeset> where Changeset.Collection == Array2D<HomeSection, HomeCell> {

    override init() {
        super.init { (items, indexPath, uiTableView) in
            let element = items[childAt: indexPath]
            let tableView = uiTableView as! TableView
            switch element.item {
            case .song(let songCellViewModel):
                let cell = tableView.dequeue(SongCell.self, indexPath: indexPath)
                cell.configure(with: songCellViewModel)
                return cell
            case .action(let actionCellViewModel):
                let cell = tableView.dequeue(ActionCell.self, indexPath: indexPath)
                cell.configure(with: actionCellViewModel)
                return cell
            default:
                fatalError("Invalid cell")
            }
        }
    }
    
    @objc private func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        changeset?.collection[sectionAt: section].metadata.localizedTitle
    }
    
}
