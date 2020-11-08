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
    
    var flowLyrics: ((SharedSong, UIImage?) -> Void)?
    
    var flowSetup: DefaultSetupModeAction?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupObservers()
        
        if viewModel.shouldSignUp {
            flowSetup?(.initial)
        } else {
            viewModel.loadData()
        }
    }

}

extension HomeViewController {
    
    // MARK: - Setup
    
    func setupView() {
        tableView.register(SongCell.self)
        tableView.register(ActionCell.self)
    }
    
    func setupObservers() {
        viewModel.items.bind(to: tableView, using: HomeBinder())
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
        navigationItem.rightBarButtonItem?.reactive.tap.throttle(for: 0.5).observeNext { [self] _ in
            Haptic.play(".")
            flowSetup?(.manual)
        }.dispose(in: disposeBag)
        tableView.reactive.selectedRowIndexPath.observeNext { [self] indexPath in
            lastSelectedIndexPath = indexPath
            tableView.deselectRow(at: indexPath, animated: true)
            Haptic.play(".")
            let cell = viewModel.items[itemAt: indexPath]
            if case .song(let viewModel) = cell {
                flowLyrics?(viewModel.song, (tableView.cellForRow(at: indexPath) as? SongCell)?.currentImage)
            }
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
