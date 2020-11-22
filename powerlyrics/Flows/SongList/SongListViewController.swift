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

// MARK: - Constants

fileprivate extension Constants {
    
    static var albumNotFoundAlert: UIAlertController {
        UIAlertController(
            title: Strings.SongList.AlbumNotFound.title,
            message: Strings.SongList.AlbumNotFound.message,
            preferredStyle: .alert
        )
    }
    
}

// MARK: - SongListViewController

class SongListViewController: ViewController, SongListScene {
    
    // MARK: - Outlets
    
    @IBOutlet private var tableView: TableView!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Instance properties
    
    var viewModel: SongListViewModel!
    
    var lastSelectedIndexPath: IndexPath?
    
    var initialLoad = true
    
    var translationInteractor: TranslationAnimationInteractor?
    
    // MARK: - Flows
    
    var flowLyrics: DefaultSharedSongPreviewAction?
    
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
        
        lastSelectedIndexPath = nil
        
        if !initialLoad {
            if viewModel is SongListLikedViewModel {
                viewModel.loadData()
            }
        }
        
        initialLoad = false
    }
    
}

// MARK: - Setup

extension SongListViewController {
    
    // MARK: - View

    func setupView() {
        
        tableView.register(LoadingCell.self)
        tableView.register(SongCell.self)
        
        translationInteractor = TranslationAnimationInteractor(viewController: self, pop: true)
        
    }
    
    // MARK: - Input
    
    func setupInput() {
        
        tableView.reactive.selectedRowIndexPath.observeNext { [weak self] indexPath in
            guard let self = self else { return }
            
            self.lastSelectedIndexPath = indexPath
            self.tableView.deselectRow(at: indexPath, animated: true)
            Haptic.play(Constants.tinyTap)
            let item = self.viewModel.items[indexPath.row]
            
            if case .song(let songCellViewModel) = item {
                self.flowLyrics?(songCellViewModel.song, (self.tableView.cellForRow(at: indexPath) as? SongCell)?.currentImage)
            }
        }.dispose(in: disposeBag)
        
    }
    
    // MARK: - Output
    
    func setupOutput() {

        viewModel.items.bind(to: tableView) { items, indexPath, uiTableView in
            let tableView = uiTableView as! TableView
            let item = items[indexPath.row]
            switch item {
            case .loading:
                let cell = tableView.dequeue(LoadingCell.self, indexPath: indexPath)
                cell.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                cell.separatorInset = UIEdgeInsets.zero.with { $0.left = .greatestFiniteMagnitude }
                return cell
                
            case .song(let songCellViewModel):
                let cell = tableView.dequeue(SongCell.self, indexPath: indexPath)
                cell.configure(with: songCellViewModel)
                return cell
            }
        }.dispose(in: disposeBag)
        
        viewModel.isRefreshing.observeNext { [weak self] isRefreshing in
            self?.tableView.isRefreshing = isRefreshing
        }.dispose(in: disposeBag)
        
        viewModel.isLoading.dropFirst(.one).observeNext { [weak self] loading in
            guard let self = self else { return }
            
            UIView.fadeDisplay(self.activityIndicator, visible: loading)
            
            if loading {
                self.tableView.unsetRefreshControl()
            } else {
                self.tableView.setRefreshControl { [weak self] in
                    self?.viewModel.loadData(refresh: true)
                }
                self.scrollToTop()
            }
        }.dispose(in: disposeBag)
        
        combineLatest(
            viewModel.items.map(\.collection.isEmpty),
            viewModel.isLoading,
            viewModel.isRefreshing,
            viewModel.isFailed,
            viewModel.isLoadingWithPreview,
            viewModel.couldntFindAlbumError
        ).dropFirst(.two).map { isEmpty, isLoading, isRefreshing, isFailed, isLoadingWithPreview, couldntFindAlbum in
            isEmpty && !isLoading && !isRefreshing && !isFailed && !isLoadingWithPreview && !couldntFindAlbum
        }.removeDuplicates().observeNext { [weak self] isVisible in
            self?.setEmptyView(isVisible: isVisible)
        }.dispose(in: disposeBag)
        
        viewModel.isFailed.removeDuplicates().dropFirst(.one).observeNext { [weak self] isFailed in
            self?.setNoInternetView(isVisible: isFailed) {
                self?.viewModel.loadData(retry: true)
            }
        }.dispose(in: disposeBag)
        
        viewModel.couldntFindAlbumError.observeNext { [weak self] couldntFindAlbum in
            guard couldntFindAlbum else { return }
            self?.present(Constants.albumNotFoundAlert.with {
                $0.addAction(UIAlertAction(title: Constants.ok, style: .default, handler: { [weak self] _ in
                    _ = self?.navigationController?.popViewController(animated: true)
                }))
            }, animated: true, completion: nil)
        }.dispose(in: disposeBag)
        
    }
    
}

// MARK: - TranslationAnimationView

extension SongListViewController: TranslationAnimationView {
    
    var translationViews: [UIView] {
        guard let indexPath = lastSelectedIndexPath,
              let container = (tableView.cellForRow(at: indexPath) as? SongCell)?.songContainer else { return [] }
        return [container]
    }

}
