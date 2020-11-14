//
//  SearchViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
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
    
    // MARK: - Instance properties
    
    var viewModel: SearchViewModel!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private var lastSelectedIndexPath: IndexPath?
    
    // MARK: - Flows
    
    var flowLyrics: ((SharedSong, UIImage?) -> Void)?
    
    var flowAlbum: ((SpotifyAlbum) -> Void)?
    
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
        searchController.searchBar.reactive.text.compactMap { $0 }.dropFirst(1).debounce(for: 0.3, queue: .main).observeNext { [self] query in
            viewModel.search(for: query)
            UIView.transition(
                with: noResultsView,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: {
                    noResultsView.isHidden = !query.isEmpty
                }
            )
        }.dispose(in: disposeBag)
        
        combineLatest(viewModel.items, viewModel.isLoading, viewModel.isRefreshing).observeNext { [self] songs, isLoading, isRefreshing in
            UIView.transition(
                with: noResultsView,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: {
                    noResultsView.isHidden = isLoading || isRefreshing || (songs.collection.numberOfSections > 0 && songs.collection.numberOfItems(inSection: 0) > 0)
                }
            )
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
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
                activityIndicator.alpha = loading ? 1 : 0
                tableView.alpha = loading ? 0.3 : 1
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
            Haptic.play(".")
            let item = viewModel.items[itemAt: indexPath]
            if case .song(let songViewModel) = item {
                flowLyrics?(songViewModel.song, (tableView.cellForRow(at: indexPath) as? SongCell)?.currentImage)
            }
        }.dispose(in: disposeBag)
        
        viewModel.trends.bind(to: trendsCollectionView, cellType: TrendCell.self) { cell, cellViewModel in
            cell.configure(with: cellViewModel)
            cell.didTap = { [self] in
                UIView.transition(
                    with: noResultsView,
                    duration: 0.3,
                    options: .transitionCrossDissolve,
                    animations: {
                        noResultsView.isHidden = true
                    }
                )
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
        UIView.transition(
            with: noResultsView,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: { [self] in
                noResultsView.isHidden = false
            }
        )
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
