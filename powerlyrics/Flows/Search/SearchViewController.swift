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

// MARK: - Constants

fileprivate extension Constants {
    
    static let nothingWasFoundText = Strings.Search.nothingWasFound
    static let startTypingText = Strings.Search.startTyping
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        lastSelectedIndexPath = nil
    }
    
    // MARK: - Actions
    
    @objc private func dismissKeyboard() {
        if !viewModel.isLoading.value {
            searchController.dismiss(animated: true)
        }
    }
    
    override func keyboardWillShow(frame: CGRect) {
        super.keyboardWillShow(frame: frame)
        
        UIView.animate { [weak self] in
            guard let self = self else { return }
            let tabBarHeight = (self.tabBarController?.tabBar.frame.height).safe
            self.tableView.contentInset.bottom = frame.height - tabBarHeight
            self.tableView.verticalScrollIndicatorInsets.bottom = frame.height - tabBarHeight
        }
    }
    
    override func keyboardWillHide(frame: CGRect) {
        super.keyboardWillHide(frame: frame)
        
        UIView.animate { [weak self] in
            self?.tableView.contentInset.bottom = .zero
            self?.tableView.verticalScrollIndicatorInsets.bottom = .zero
        }
    }
        
}

// MARK: - Setup

extension SearchViewController {
    
    // MARK: - View

    func setupView() {
        
        tableView.register(SongCell.self)
        tableView.register(SearchAlbumsCell.self)
        
        tableView.keyboardDismissMode = .interactive
        
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
        
        searchController.searchBar
            .reactive.text
            .compactMap { $0 }
            .dropFirst(.one)
            .debounce(for: Constants.buttonThrottleTime, queue: .main)
            .observeNext { [weak self] query in
                guard let self = self, !self.viewModel.isCancelled.value else { return }
                self.viewModel.search(for: query)
            }.dispose(in: disposeBag)
        
        tableView.reactive.selectedRowIndexPath.observeNext { [weak self] indexPath in
            guard let self = self else { return }
            self.lastSelectedIndexPath = indexPath
            self.tableView.deselectRow(at: indexPath, animated: true)
            Haptic.play(Constants.tinyTap)
            let item = self.viewModel.items[itemAt: indexPath]
            if case .song(let songViewModel) = item {
                self.flowLyrics?(
                    songViewModel.song,
                    (self.tableView.cellForRow(at: indexPath) as? SongCell)?.currentImage
                )
            }
        }.dispose(in: disposeBag)
        
        reloadTrendsButton.reactive.tap.observeNext { [weak self] _ in
            self?.viewModel.loadTrends()
        }.dispose(in: disposeBag)
        
    }
    
    // MARK: - Output
    
    func setupOutput() {
        
        viewModel.items.bind(to: tableView, using: SearchBinder(albumTapAction: { [weak self] album in
            Haptic.play(Constants.tinyTap)
            self?.flowAlbum?(album)
        })).dispose(in: disposeBag)
        
        viewModel.trends.bind(to: trendsCollectionView, cellType: SearchTrendCell.self) { cell, cellViewModel in
            cell.configure(with: cellViewModel)
            cell.didTap = { [weak self] in
                guard let self = self else { return }
                Haptic.play(Constants.tinyTap)
                let query = "\(cellViewModel.song.name) \(Constants.dash) \(cellViewModel.song.artists.first.safe)"
                self.searchController.searchBar.text = query
                self.searchController.isActive = true
                self.searchController.searchBar.setShowsCancelButton(true, animated: true)
                self.viewModel.search(for: query)
            }
        }.dispose(in: disposeBag)
        
        viewModel.trendsFailed.observeNext { [weak self] failed in
            guard let self = self else { return }
            UIView.fadeDisplay(self.trendsFailStackView, visible: failed)
        }.dispose(in: disposeBag)
        
        viewModel.isFailed.observeNext { [weak self] isFailed in
            guard let self = self else { return }
            self.setNoInternetView(isVisible: isFailed) {
                let text = self.searchController.searchBar.text.safe
                self.viewModel.search(for: text)
            }
        }.dispose(in: disposeBag)
        
        combineLatest(viewModel.items, viewModel.isLoading, viewModel.isRefreshing, viewModel.isFailed).map { songs, isLoading, isRefreshing, isFailed in
            (!isLoading && !isRefreshing &&
                (songs.collection.numberOfSections == .zero ||
                    songs.collection.numberOfItems(inSection: .zero) == .zero)) && !isFailed
        }.removeDuplicates().observeNext { [weak self] isVisible in
            guard let self = self else { return }
            UIView.fadeDisplay(self.noResultsView, visible: isVisible)
        }.dispose(in: disposeBag)
        
        viewModel.trendsLoading.dropFirst(.one).observeNext(with: { [weak self] isLoading in
            guard let self = self else { return }
            UIView.fadeDisplay(self.trendsActivityIndicator, visible: isLoading)
        }).dispose(in: disposeBag)
        
        viewModel.isRefreshing.observeNext { [weak self] isRefreshing in
            self?.tableView.isRefreshing = isRefreshing
        }.dispose(in: disposeBag)
        
        viewModel.isLoading.removeDuplicates().observeNext { [weak self] loading in
            guard let self = self else { return }
            
            if loading {
                self.tableView.isUserInteractionEnabled = false
                self.tableView.isScrollEnabled = false
            }
            
            UIView.fadeDisplay(self.activityIndicator, visible: loading, duration: .pointOne)
            
            UIView.animate(withDuration: .pointOne, delay: .zero, options: .curveEaseOut) {
                self.tableView.alpha = loading ? .pointThree : .one
            } completion: { _ in
                if !loading {
                    self.tableView.isUserInteractionEnabled = true
                    self.tableView.isScrollEnabled = true
                }
            }
            
            if loading {
                self.tableView.unsetRefreshControl()
            } else {
                self.tableView.setRefreshControl { [weak self] in
                    guard let self = self else { return }
                    self.viewModel.search(for: self.searchController.searchBar.text.safe, refresh: true)
                }
                self.scrollToTop()
            }
        }.dispose(in: disposeBag)
        
        viewModel.nothingWasFound.map {
            $0 ? Constants.nothingWasFoundText :
                Constants.startTypingText
        }.observeNext { [weak self] text in
            guard let self = self else { return }
            UIView.fadeUpdate(self.nothingWasFoundSubtitleLabel) { [weak self] in
                self?.nothingWasFoundSubtitleLabel.text = text
            }
        }.dispose(in: disposeBag)
    
    }
    
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.cancelLoading()
        viewModel.reset()
        viewModel.isCancelled.value = true
        
        delay(Constants.buttonThrottleTime) { [weak self] in
            self?.viewModel.isCancelled.value = false
        }
        
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
                
            case .albums(let searchAlbumsCellViewModel):
                let cell = tableView.dequeue(SearchAlbumsCell.self, indexPath: indexPath)
                cell.configure(with: searchAlbumsCellViewModel)
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
