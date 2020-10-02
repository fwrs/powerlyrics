//
//  HomeView.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Bond
import ReactiveKit
import UIKit

class HomeViewController: ViewController, HomeScene {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: TableView!
    
    // MARK: - Instance properties
    
    var viewModel: HomeViewModel!
    
    // MARK: - Flows
    
    var flowSample: DefaultAction?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupObservers()
    }
    
    // MARK: - Actions
    
    @IBAction private func addAccountPressed(_ sender: UIBarButtonItem) {
        flowSample?()
    }
    
}

extension HomeViewController {
    
    // MARK: - Setup
    
    func setupObservers() {
        viewModel.songs.bind(to: tableView, cellType: SongCell.self) { (cell, cellViewModel) in
            cell.configure(with: cellViewModel)
        }
        let refreshControl = tableView.setRefreshControl { [self] in
            guard !viewModel.isLoading.value else { return }
            delay(0.2) {
                tableView.refreshControl?.endRefreshing()
            }
        }
        viewModel.isLoading.bind(to: refreshControl.reactive.refreshing)
        tableView.reactive.selectedRowIndexPath.observeNext { [self] indexPath in
            tableView.deselectRow(at: indexPath, animated: true)
        }.dispose(in: disposeBag)
    }
    
}
