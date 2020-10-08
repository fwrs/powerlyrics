//
//  SearchViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//

import UIKit

class SearchViewController: ViewController, SearchScene {
    
    // MARK: - Outlets
    
    @IBOutlet private var tableView: TableView!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Instance properties
    
    var viewModel: SearchViewModel!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupObservers()
    }
    
    // MARK: - Actions
    
    override func keyboardWillHide(notification: Notification) {
        super.keyboardWillHide(notification: notification)
        searchController.isActive = false
    }
    
}

extension SearchViewController {
    
    // MARK: - Setup

    func setupView() {
        tableView.setRefreshControl()
        searchController.searchBar.searchTextField.leftView?.tintColor = .secondaryLabel
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        navigationItem.scrollEdgeAppearance = appearance
        addKeyboardWillHideNotification()
    }
    
    func setupObservers() {
        searchController.searchBar.reactive.text.compactMap { $0 }.filter(\.nonEmpty).debounce(for: 0.5, queue: .main).observeNext { [self] query in
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
            tableView.deselectRow(at: indexPath, animated: true)
        }.dispose(in: disposeBag)
    }
    
}
