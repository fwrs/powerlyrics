//
//  SongListViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/14/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import Haptica
import ReactiveKit
import UIKit

class SongListViewController: ViewController, SongListScene {
    
    // MARK: - Outlets
    
    @IBOutlet private var tableView: TableView!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Instance properties
    
    var viewModel: SongListViewModel!
    
    private var lastSelectedIndexPath: IndexPath?
    
    var initial = true
    
    // MARK: - Flows
    
    var flowLyrics: DefaultSharedSongPreviewAction?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupObservers()
        
        viewModel.loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !initial {
            if viewModel.flow == .likedSongs {
                viewModel.loadData()
            }
        }
        initial = false
    }
    
}

extension SongListViewController {
    
    // MARK: - Setup

    func setupView() {
        tableView.register(SongCell.self)
        tableView.register(LoadingCell.self)
        tableView.cellLayoutMarginsFollowReadableWidth = false
    }
    
    func setupObservers() {
        viewModel.title.map { $0.lowercased() }.bind(to: navigationItem.reactive.title).dispose(in: disposeBag)
        viewModel.items.bind(to: tableView) { items, indexPath, uiTableView in
            let tableView = uiTableView as! TableView
            let item = items[indexPath.row]
            switch item {
            case .song(let songCellViewModel):
                let cell = tableView.dequeue(SongCell.self, indexPath: indexPath)
                cell.configure(with: songCellViewModel)
                return cell
            case .loading:
                let cell = tableView.dequeue(LoadingCell.self, indexPath: indexPath)
                cell.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                cell.separatorInset = UIEdgeInsets(top: 0, left: .greatestFiniteMagnitude, bottom: 0, right: 0)
                return cell
            }
        }
        
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
        tableView.reactive.selectedRowIndexPath.observeNext { [self] indexPath in
            lastSelectedIndexPath = indexPath
            tableView.deselectRow(at: indexPath, animated: true)
            Haptic.play(Constants.tinyTap)
            let item = viewModel.items[indexPath.row]
            if case .song(let songCellViewModel) = item {
                flowLyrics?(songCellViewModel.song, (tableView.cellForRow(at: indexPath) as? SongCell)?.currentImage)
            }
        }.dispose(in: disposeBag)
        combineLatest(viewModel.items.map(\.collection.isEmpty), viewModel.isLoading, viewModel.isRefreshing, viewModel.failed, viewModel.isLoadingWithPreview).dropFirst(2).observeNext { [self] isEmpty, isLoading, isRefreshing, isFailed, isLoadingWithPreview in
            setEmptyView(isVisible: isEmpty && !isLoading && !isRefreshing && !isFailed && !isLoadingWithPreview)
        }.dispose(in: disposeBag)
        viewModel.failed.observeNext { [self] isFailed in
            setNoInternetView(isVisible: isFailed) {
                viewModel.loadData()
            }
        }.dispose(in: disposeBag)
    }
    
}

extension SongListViewController: TranslationAnimationView {
    
    var translationViews: [UIView] {
        guard let indexPath = lastSelectedIndexPath,
              let container = (tableView.cellForRow(at: indexPath) as? SongCell)?.songContainer else { return [] }
        return [container]
    }
    
    var translationInteractor: TranslationAnimationInteractor? { nil }

}
