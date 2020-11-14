//
//  SongListViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 14.11.20.
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
    
    // MARK: - Flows
    
    var flowLyrics: ((SharedSong, UIImage?) -> Void)?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupObservers()
        
        viewModel.loadData()
    }
    
}

extension SongListViewController {
    
    // MARK: - Setup

    func setupView() {
        tableView.register(SongCell.self)
    }
    
    func setupObservers() {
        viewModel.title.bind(to: navigationItem.reactive.title).dispose(in: disposeBag)
        viewModel.songs.bind(to: tableView, cellType: SongCell.self) { songCell, songCellViewModel in
            songCell.configure(with: songCellViewModel)
        }
        
        viewModel.isRefreshing.observeNext { [self] isRefreshing in
            tableView.isRefreshing = isRefreshing
        }.dispose(in: disposeBag)
        viewModel.isLoading.observeNext { [self] loading in
            UIView.animate(withDuration: 0.35) {
                activityIndicator.alpha = loading ? 1 : 0
            }
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
            Haptic.play(".")
            let songCellViewModel = viewModel.songs[indexPath.row]
            flowLyrics?(songCellViewModel.song, (tableView.cellForRow(at: indexPath) as? SongCell)?.currentImage)
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
