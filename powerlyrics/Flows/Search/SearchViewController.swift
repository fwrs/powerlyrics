//
//  SearchViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Bond
import Haptica
import ReactiveKit
import UIKit

class SearchViewController: ViewController, SearchScene {
    
    // MARK: - Outlets
    
    @IBOutlet private var tableView: TableView!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var noResultsView: UIView!
    
    @IBOutlet private weak var trendsCollectionView: UICollectionView!
    
    @IBOutlet private weak var trendsActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var searchIconImageView: UIImageView!
    
    @IBOutlet private weak var nothingWasFoundSubtitleLabel: UILabel!
    
    @IBOutlet private weak var trendsFailStackView: UIStackView!
        
    // MARK: - Instance properties
    
    var viewModel: SearchViewModel!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private var lastSelectedIndexPath: IndexPath?
    
    // MARK: - Flows
    
    var flowLyrics: DefaultSharedSongPreviewAction?
    
    var flowAlbum: DefaultSpotifyAlbumAction?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupObservers()
        
        viewModel.loadTrends()
    }
    
    // MARK: - Actions
    
    @objc func dismissKeyboard() {
        if !viewModel.isLoading.value {
            searchController.dismiss(animated: true)
        }
    }
    
    @IBAction private func tappedReloadTrendsButton(_ sender: Any) {
        viewModel.loadTrends()
    }
        
}

extension SearchViewController {
    
    // MARK: - Setup

    func setupView() {
        searchController.searchBar.searchTextField.leftView?.tintColor = .secondaryLabel
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        navigationItem.scrollEdgeAppearance = appearance
        addKeyboardWillHideNotification()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        searchIconImageView.image = searchIconImageView.image?.withTintColor(.label, renderingMode: .alwaysOriginal)
        
        tableView.register(SongCell.self)
        tableView.register(AlbumsCell.self)
    }
    
    func setupObservers() {
        viewModel.trendsFailed.observeNext { [self] failed in
            trendsFailStackView.fadeDisplay(visible: failed)
        }.dispose(in: disposeBag)
        viewModel.internetError.observeNext { [self] isError in
            setNoInternetView(isVisible: isError) {
                let text = searchController.searchBar.text.safe
                viewModel.search(for: text)
            }
            noResultsView.fadeDisplay(visible: !isError && searchController.searchBar.text.safe.isEmpty)
        }.dispose(in: disposeBag)
        searchController.searchBar.reactive.text.compactMap { $0 }.dropFirst(1).debounce(for: Constants.buttonThrottleTime, queue: .main).observeNext { [self] query in
            viewModel.search(for: query)
            noResultsView.fadeDisplay(visible: query.isEmpty)
        }.dispose(in: disposeBag)
        
        combineLatest(viewModel.items, viewModel.isLoading, viewModel.isRefreshing, viewModel.internetError).observeNext { [self] songs, isLoading, isRefreshing, isError in
            if isError { return }
            noResultsView.fadeDisplay(visible: !isLoading && !isRefreshing &&
                (songs.collection.numberOfSections == .zero ||
                    songs.collection.numberOfItems(inSection: .zero) == .zero))
        }.dispose(in: disposeBag)
        
        viewModel.trendsAreLoading.map(\.negated).bind(to: trendsActivityIndicator.reactive.isHidden).dispose(in: disposeBag)
        
        viewModel.isRefreshing.observeNext { [self] isRefreshing in
            tableView.isRefreshing = isRefreshing
        }.dispose(in: disposeBag)
        viewModel.isLoading.removeDuplicates().observeNext { [self] loading in
            if loading {
                tableView.isUserInteractionEnabled = false
                tableView.isScrollEnabled = false
            }
            activityIndicator.fadeDisplay(visible: loading, duration: .oOne)
            UIView.animate(withDuration: .oOne, delay: .zero, options: .curveEaseOut) {
                tableView.alpha = loading ? .oThree : .one
            } completion: { _ in
                if !loading {
                    tableView.isUserInteractionEnabled = true
                    tableView.isScrollEnabled = true
                }
            }
            if loading {
                tableView.unsetRefreshControl()
            } else {
                tableView.setRefreshControl { [self] in
                    viewModel.search(for: searchController.searchBar.text.safe, refresh: true)
                }
                scrollToTop()
            }
        }.dispose(in: disposeBag)
        
        viewModel.items.bind(to: tableView, using: SearchBinder(albumTapAction: { [self] album in
            flowAlbum?(album)
        }))
        tableView.reactive.selectedRowIndexPath.observeNext { [self] indexPath in
            lastSelectedIndexPath = indexPath
            tableView.deselectRow(at: indexPath, animated: true)
            Haptic.play(Constants.tinyTap)
            let item = viewModel.items[itemAt: indexPath]
            if case .song(let songViewModel) = item {
                flowLyrics?(songViewModel.song, (tableView.cellForRow(at: indexPath) as? SongCell)?.currentImage)
            }
        }.dispose(in: disposeBag)
        
        viewModel.trends.bind(to: trendsCollectionView, cellType: TrendCell.self) { cell, cellViewModel in
            cell.configure(with: cellViewModel)
            cell.didTap = { [self] in
                Haptic.play(Constants.tinyTap)
                noResultsView.fadeHide()
                let query = "\(cellViewModel.song.name) - \(cellViewModel.song.artists.first.safe)"
                searchController.searchBar.text = query
                searchController.isActive = true
                searchController.searchBar.setShowsCancelButton(true, animated: true)
                viewModel.search(for: query)
            }
        }
        
        viewModel.nothingWasFound.map { $0 ? "Nothing was found\nfor your query" : "Start typing to\nreceive suggestions" }.bind(to: nothingWasFoundSubtitleLabel.reactive.text).dispose(in: disposeBag)
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard !viewModel.isLoading.value && !viewModel.isRefreshing.value else { return }
        viewModel.reset()
        noResultsView.fadeShow()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
}

extension SearchViewController: TranslationAnimationView {
    
    var translationViews: [UIView] {
        guard let indexPath = lastSelectedIndexPath,
              let container = (tableView.cellForRow(at: indexPath) as? SongCell)?.songContainer else { return [] }
        return [container]
    }
    
    var translationInteractor: TranslationAnimationInteractor? { nil }

}
