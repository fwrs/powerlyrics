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
    
    // MARK: - Instance properties
    
    var viewModel: SearchViewModel!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private var lastSelectedIndexPath: IndexPath?
    
    // MARK: - Flows
    
    var flowLyrics: DefaultSongAction?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupObservers()
    }
    
    // MARK: - Actions
    
    @objc func dismissKeyboard() {
        searchController.dismiss(animated: true)
    }
    
}

extension SearchViewController {
    
    // MARK: - Setup

    func setupView() {
        tableView.setRefreshControl()
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
    }
    
    func setupObservers() {
        searchController.searchBar.reactive.text.compactMap { $0 }.filter(\.nonEmpty).debounce(for: 0.3, queue: .main).observeNext { [self] query in
            viewModel.search(for: query)
        }.dispose(in: disposeBag)
        viewModel.isLoading.bind(to: activityIndicator.reactive.isAnimating).dispose(in: disposeBag)
        viewModel.isLoading.observeNext { [self] loading in
            if loading {
                tableView.unsetRefreshControl()
            } else {
                tableView.setRefreshControl()
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
            flowLyrics?(songViewModel.song)
        }.dispose(in: disposeBag)
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // reset search
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
