//
//  HomeView.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Bond
import Haptica
import ReactiveKit
import UIKit

class HomeViewController: ViewController, HomeScene {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: TableView!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Instance properties
    
    var viewModel: HomeViewModel!
    
    private var lastSelectedIndexPath: IndexPath?
    
    // MARK: - Flows
    
    var flowLyrics: DefaultSongAction?
    
    var flowSetup: DefaultSetupModeAction?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupObservers()
        
        flowSetup?(.initial)
    }

}

extension HomeViewController {
    
    // MARK: - Setup
    
    func setupView() {}
    
    func setupObservers() {
        viewModel.songs.bind(to: tableView, cellType: SongCell.self) { (cell, cellViewModel) in
            cell.configure(with: cellViewModel)
        }
        viewModel.isLoading.bind(to: activityIndicator.reactive.isAnimating).dispose(in: disposeBag)
        viewModel.isLoading.observeNext { [self] loading in
            if loading {
                tableView.unsetRefreshControl()
            } else {
                tableView.setRefreshControl()
                scrollToTop()
            }
        }.dispose(in: disposeBag)
        navigationItem.rightBarButtonItem?.reactive.tap.throttle(for: 0.5).observeNext { [self] _ in
            Haptic.play(".")
            flowSetup?(.manual)
        }.dispose(in: disposeBag)
        tableView.reactive.selectedRowIndexPath.observeNext { [self] indexPath in
            lastSelectedIndexPath = indexPath
            tableView.deselectRow(at: indexPath, animated: true)
            Haptic.play(".")
            let songViewModel = viewModel.songs[indexPath.item]
            flowLyrics?(Song(name: songViewModel.songName, artistName: songViewModel.artistName, albumArt: songViewModel.albumArt))
        }.dispose(in: disposeBag)
    }
    
}

extension HomeViewController: TranslationAnimationView {
    
    var translationViews: [UIView] {
        guard let indexPath = lastSelectedIndexPath,
              let container = (tableView.cellForRow(at: indexPath) as? SongCell)?.songContainer else { return [] }
        return [container]
    }
    
    var translationInteractor: TranslationAnimationInteractor? { nil }

}
