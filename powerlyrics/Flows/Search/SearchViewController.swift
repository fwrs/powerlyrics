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

// MARK: - Constants

fileprivate extension Constants {
    
    static let nothingWasFoundText = "Nothing was found\nfor your query"
    static let startTypingText = "Start typing to\nreceive suggestions"
    
}

// MARK: - SearchViewController

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
        
    @IBOutlet private weak var reloadTrendsButton: UIButton!
    
    // MARK: - Instance properties
    
    var viewModel: SearchViewModel!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var lastSelectedIndexPath: IndexPath?
    
    // MARK: - Flows
    
    var flowLyrics: DefaultSharedSongPreviewAction?
    
    var flowAlbum: DefaultSpotifyAlbumAction?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupInput()
        setupOutput()
        
        viewModel.loadTrends()
    }
    
    // MARK: - Actions
    
    @objc private func dismissKeyboard() {
        if !viewModel.isLoading.value {
            searchController.dismiss(animated: true)
        }
    }
    
    override func keyboardWillShow(frame: CGRect) {
        super.keyboardWillShow(frame: frame)
        
        UIView.animate { [self] in
            tableView.contentInset.bottom = frame.height - (tabBarController?.tabBar.frame.height).safe
            tableView.verticalScrollIndicatorInsets.bottom = frame.height - (tabBarController?.tabBar.frame.height).safe
        }
    }
    
    override func keyboardWillHide(frame: CGRect) {
        super.keyboardWillHide(frame: frame)
        
        UIView.animate { [self] in
            tableView.contentInset.bottom = .zero
            tableView.verticalScrollIndicatorInsets.bottom = .zero
        }
    }
        
}

// MARK: - Setup

extension SearchViewController {
    
    // MARK: - View

    func setupView() {
        tableView.register(SongCell.self)
        tableView.register(AlbumsCell.self)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        navigationItem.scrollEdgeAppearance = appearance
        
        searchController.searchBar.searchTextField.leftView?.tintColor = .secondaryLabel
        searchController.searchBar.autocorrectionType = .yes
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController

        addKeyboardWillShowNotification()
        addKeyboardWillHideNotification()

        searchIconImageView.image = searchIconImageView.image?.withTintColor(.label, renderingMode: .alwaysOriginal)
    }
    
    // MARK: - Input
    
    func setupInput() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        searchController.searchBar.reactive.text.compactMap { $0 }.dropFirst(.one).debounce(for: Constants.buttonThrottleTime, queue: .main).observeNext { [self] query in
            viewModel.search(for: query)
            UIView.fadeDisplay(noResultsView, visible: query.isEmpty)
        }.dispose(in: disposeBag)
        
        tableView.reactive.selectedRowIndexPath.observeNext { [self] indexPath in
            lastSelectedIndexPath = indexPath
            tableView.deselectRow(at: indexPath, animated: true)
            Haptic.play(Constants.tinyTap)
            let item = viewModel.items[itemAt: indexPath]
            if case .song(let songViewModel) = item {
                flowLyrics?(songViewModel.song, (tableView.cellForRow(at: indexPath) as? SongCell)?.currentImage)
            }
        }.dispose(in: disposeBag)
        
        reloadTrendsButton.reactive.tap.observeNext { [self] _ in
            viewModel.loadTrends()
        }.dispose(in: disposeBag)
        
    }
    
    // MARK: - Output
    
    func setupOutput() {
        
        viewModel.trendsFailed.observeNext { [self] failed in
            UIView.fadeDisplay(trendsFailStackView, visible: failed)
        }.dispose(in: disposeBag)
        
        viewModel.isFailed.observeNext { [self] isFailed in
            setNoInternetView(isVisible: isFailed) {
                let text = searchController.searchBar.text.safe
                viewModel.search(for: text)
            }
            UIView.fadeDisplay(noResultsView, visible: !isFailed && searchController.searchBar.text.safe.isEmpty)
        }.dispose(in: disposeBag)
        
        combineLatest(viewModel.items, viewModel.isLoading, viewModel.isRefreshing, viewModel.isFailed).observeNext { [self] songs, isLoading, isRefreshing, isFailed in
            if isFailed { return }
            UIView.fadeDisplay(noResultsView, visible: !isLoading && !isRefreshing &&
                (songs.collection.numberOfSections == .zero ||
                    songs.collection.numberOfItems(inSection: .zero) == .zero))
        }.dispose(in: disposeBag)
        
        viewModel.trendsLoading.observeNext(with: { [self] isLoading in
            UIView.fadeDisplay(trendsActivityIndicator, visible: isLoading)
        }).dispose(in: disposeBag)
        
        viewModel.isRefreshing.observeNext { [self] isRefreshing in
            tableView.isRefreshing = isRefreshing
        }.dispose(in: disposeBag)
        
        viewModel.isLoading.removeDuplicates().observeNext { [self] loading in
            if loading {
                tableView.isUserInteractionEnabled = false
                tableView.isScrollEnabled = false
            }
            UIView.fadeDisplay(activityIndicator, visible: loading, duration: .pointOne)
            UIView.animate(withDuration: .pointOne, delay: .zero, options: .curveEaseOut) {
                tableView.alpha = loading ? .pointThree : .one
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
        
        viewModel.trends.bind(to: trendsCollectionView, cellType: TrendCell.self) { cell, cellViewModel in
            cell.configure(with: cellViewModel)
            cell.didTap = { [self] in
                Haptic.play(Constants.tinyTap)
                UIView.fadeHide(noResultsView)
                let query = "\(cellViewModel.song.name) \(Constants.dash) \(cellViewModel.song.artists.first.safe)"
                searchController.searchBar.text = query
                searchController.isActive = true
                searchController.searchBar.setShowsCancelButton(true, animated: true)
                viewModel.search(for: query)
            }
        }
        
        viewModel.nothingWasFound.map {
            $0 ?
                Constants.nothingWasFoundText :
                Constants.startTypingText
        }.bind(to: nothingWasFoundSubtitleLabel.reactive.text).dispose(in: disposeBag)
    
    }
    
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard !viewModel.isLoading.value && !viewModel.isRefreshing.value else { return }
        viewModel.reset()
        UIView.fadeShow(noResultsView)
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
}

// MARK: - TranslationAnimationView

extension SearchViewController: TranslationAnimationView {
    
    var translationViews: [UIView] {
        guard let indexPath = lastSelectedIndexPath,
              let container = (tableView.cellForRow(at: indexPath) as? SongCell)?.songContainer else { return [] }
        return [container]
    }

}

// MARK: - SearchBinder

class SearchBinder<Changeset: SectionedDataSourceChangeset>: TableViewBinderDataSource<Changeset> where Changeset.Collection == Array2D<SearchSection, SearchCell> {
    
    init(albumTapAction: @escaping DefaultSpotifyAlbumAction) {
        super.init { (items, indexPath, uiTableView) in
            let element = items[childAt: indexPath]
            let tableView = uiTableView as! TableView
            switch element.item {
            case .song(let songCellViewModel):
                let cell = tableView.dequeue(SongCell.self, indexPath: indexPath)
                cell.configure(with: songCellViewModel)
                return cell
            case .albums(let albumsCellViewModel):
                let cell = tableView.dequeue(AlbumsCell.self, indexPath: indexPath)
                cell.configure(with: albumsCellViewModel)
                cell.didTapAlbum = albumTapAction
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
