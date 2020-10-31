//
//  SearchViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//

import Haptica
import UIKit

class SearchViewController: ViewController, SearchScene {
    
    // MARK: - Outlets
    
    @IBOutlet private var tableView: TableView!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var trendsCollectionView: UICollectionView!
    
    @IBOutlet private weak var searchIconImageView: UIImageView!
    
    // MARK: - Instance properties
    
    var viewModel: SearchViewModel!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private var lastSelectedIndexPath: IndexPath?
    
    // MARK: - Flows
    
    var flowLyrics: ((Shared.Song, UIImage?) -> Void)?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupObservers()
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
    }
    
    func setupObservers() {
        searchController.searchBar.reactive.text.compactMap { $0 }.dropFirst(1).debounce(for: 0.3, queue: .main).observeNext { [self] query in
            viewModel.search(for: query)
        }.dispose(in: disposeBag)
        
        viewModel.isRefreshing.observeNext { [self] isRefreshing in
            tableView.isRefreshing = isRefreshing
        }.dispose(in: disposeBag)
        viewModel.isLoading.observeNext { [self] loading in
            if loading {
                tableView.isUserInteractionEnabled = false
                tableView.isScrollEnabled = false
            }
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                activityIndicator.alpha = loading ? 1 : 0
                tableView.transform = loading ? .init(translationX: 0, y: 100) : .identity
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
        
        viewModel.songs.bind(to: tableView, cellType: SongCell.self, using: SearchBinder()) { (cell, cellViewModel) in
            cell.configure(with: cellViewModel)
        }.dispose(in: disposeBag)
        tableView.reactive.selectedRowIndexPath.observeNext { [self] indexPath in
            lastSelectedIndexPath = indexPath
            tableView.deselectRow(at: indexPath, animated: true)
            Haptic.play(".")
            let songViewModel = viewModel.songs[itemAt: indexPath]
            flowLyrics?(songViewModel.song, (tableView.cellForRow(at: indexPath) as? SongCell)?.currentImage)
        }.dispose(in: disposeBag)
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.reset()
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
