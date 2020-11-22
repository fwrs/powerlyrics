//
//  HomeViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import Haptica
import ReactiveKit

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
        }
        
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
        
        tableView.reactive.selectedRowIndexPath.observeNext { [weak self] indexPath in
            guard let self = self else { return }
            self.lastSelectedIndexPath = indexPath
            self.tableView.deselectRow(at: indexPath, animated: true)
            Haptic.play(Constants.tinyTap)
            let cell = self.viewModel.items[itemAt: indexPath]
            if case .song(let viewModel) = cell {
                self.flowLyrics?(viewModel.song, (self.tableView.cellForRow(at: indexPath) as? SongCell)?.currentImage)
            } else if case .action(let actionCellViewModel) = cell {
                if actionCellViewModel.action == .seeTrendingSongs {
                    self.flowTrends?(Array(self.viewModel.trendingSongs.prefix(Constants.maxPlaylistPreviewCount)))
                } else if actionCellViewModel.action == .seeViralSongs {
                    self.flowVirals?(Array(self.viewModel.viralSongs.prefix(Constants.maxPlaylistPreviewCount)))
                }
            }
        }.dispose(in: disposeBag)
        
        navigationItem.rightBarButtonItem?.reactive.tap.throttle(for: Constants.buttonThrottleTime).observeNext { [weak self] _ in
            guard let self = self else { return }
            Haptic.play(Constants.tinyTap)
            if self.viewModel.isSpotifyAccount.value {
                self.flowSafari?(Constants.accountManagementURL)
            } else {
                self.flowSetup?(.manual)
            }
        }.dispose(in: disposeBag)
        
    }
    
    // MARK: - Output
    
    func setupOutput() {
        
        viewModel.items.bind(to: tableView, using: HomeBinder()).dispose(in: disposeBag)
        
        viewModel.isSpotifyAccount.observeNext { [weak self] isSpotifyAccount in
            self?.navigationItem.rightBarButtonItem?.image = isSpotifyAccount ?
                Constants.personCheckIcon :
                Constants.personPlusIcon
        }.dispose(in: disposeBag)
        
        viewModel.isFailed.observeNext { [weak self] isFailed in
            self?.setNoInternetView(isVisible: isFailed) {
                self?.viewModel.loadData()
            }
        }.dispose(in: disposeBag)
        
        viewModel.isRefreshing.observeNext { [weak self] isRefreshing in
            self?.tableView.isRefreshing = isRefreshing
        }.dispose(in: disposeBag)
        
        viewModel.isLoading.dropFirst(.one).observeNext { [weak self] isLoading in
            guard let self = self else { return }
            UIView.fadeDisplay(self.activityIndicator, visible: isLoading)
            
            if isLoading {
                self.tableView.unsetRefreshControl()
            } else {
                self.tableView.setRefreshControl { [weak self] in
                    self?.viewModel.loadData(refresh: true)
                }
                self.scrollToTop()
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
