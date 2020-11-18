//
//  GenreMapGenreStatsViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/7/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Haptica
import PanModal
import ReactiveKit
import Then
import UIKit

// MARK: - Constants

extension Constants {
    
    static let panModalCornerRadius: CGFloat = 30
    
}

fileprivate extension Constants {
    
    static let tinyDelay = 0.01
    
    static let navigationBarBlurThreshold: CGFloat = 10
    
}

// MARK: - GenreStatsViewController

class GenreStatsViewController: ViewController, GenreStatsScene {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: TableView!
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var titleBackgroundView: UIVisualEffectView!
    
    @IBOutlet private weak var titleShadowView: UIView!
    
    // MARK: - Instance properties
    
    var viewModel: GenreStatsViewModel!
    
    var lastSelectedIndexPath: IndexPath?
    
    var initialLoad: Bool = true
    
    var navigationBarBackgroundHidden = true
    
    // MARK: - Flows
    
    var flowLyrics: DefaultSharedSongPreviewAction?
    
    var flowDismiss: DefaultAction?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupInput()
        setupOutput()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if presentedViewController == nil {
            flowDismiss?()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !initialLoad {
            viewModel.loadData()
        }
        initialLoad = false
    }
    
    // MARK: - Helper methods
    
    func updateNavigationBarAppearance() {
        if (navigationBarBackgroundHidden && tableView.contentOffset.y < Constants.navigationBarBlurThreshold) ||
            (!navigationBarBackgroundHidden && tableView.contentOffset.y >= Constants.navigationBarBlurThreshold) {
            return
        }
        navigationBarBackgroundHidden = tableView.contentOffset.y < Constants.navigationBarBlurThreshold
        titleBackgroundView.fadeDisplay(visible: tableView.contentOffset.y > Constants.navigationBarBlurThreshold)
        titleShadowView.fadeDisplay(visible: tableView.contentOffset.y > Constants.navigationBarBlurThreshold)
    }
    
}

// MARK: - Setup

extension GenreStatsViewController {
    
    // MARK: - View

    func setupView() {
        
        tableView.register(SongCell.self)
        tableView.register(GenreInfoCell.self)
        tableView.register(GenreEmptyCell.self)
        
        tableView.delegate = self
        tableView.automaticallyAdjustsScrollIndicatorInsets = false
        
        titleLabel.text = viewModel.genre.localizedName
        
        panModalSetNeedsLayoutUpdate()
        updateNavigationBarAppearance()
        
    }
    
    // MARK: - Input
    
    func setupInput() {
    
        tableView.reactive.selectedRowIndexPath.observeNext { [self] indexPath in
            tableView.deselectRow(at: indexPath, animated: true)
            lastSelectedIndexPath = indexPath
            Haptic.play(Constants.tinyTap)
            if case .song(let songCellViewModel) = viewModel.items[indexPath.row] {
                flowLyrics?(songCellViewModel.song, nil)
            }
        }.dispose(in: disposeBag)
        
    }
    
    // MARK: - Output
    
    func setupOutput() {
        
        viewModel.items.observeNext { [self] _ in
            delay(Constants.tinyDelay) {
                panModalSetNeedsLayoutUpdate()
                panModalTransition(to: .shortForm)
            }
        }.dispose(in: disposeBag)
        
        viewModel.items.bind(to: tableView, rowAnimation: .fade) { items, indexPath, uiTableView in
            let tableView = uiTableView as! TableView
            let item = items[indexPath.row]
            switch item {
            case .genreInfo(let genreInfoCellViewModel):
                let cell = tableView.dequeue(GenreInfoCell.self, indexPath: indexPath)
                cell.configure(with: genreInfoCellViewModel)
                cell.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                cell.separatorInset = .zero
                return cell
            case .song(let songCellViewModel):
                let cell = tableView.dequeue(SongCell.self, indexPath: indexPath)
                cell.configure(with: songCellViewModel)
                if items.count - 1 == indexPath.row {
                    cell.separatorInset = .zero
                } else {
                    cell.separatorInset = UIEdgeInsets().with { $0.left = Constants.space16 }
                }
                return cell
            case .empty:
                let cell = tableView.dequeue(GenreEmptyCell.self, indexPath: indexPath)
                cell.separatorInset = UIEdgeInsets().with { $0.left = tableView.bounds.width }
                cell.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                return cell
            }
        }
        
    }
    
}

// MARK: - TranslationAnimationView

extension GenreStatsViewController: TranslationAnimationView {
    
    var translationViews: [UIView] {
        guard let indexPath = lastSelectedIndexPath,
              let container = (tableView.cellForRow(at: indexPath) as? SongCell)?.songContainer else { return [] }
        return [container]
    }
    
    var isSourcePanModal: Bool { true }
    
}

// MARK: - PanModalPresentable

extension GenreStatsViewController: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        tableView
    }
    
    var panModalBackgroundColor: UIColor {
        .clear
    }
    
    var cornerRadius: CGFloat {
        Constants.panModalCornerRadius
    }
    
}

// MARK: - UITableViewDelegate

extension GenreStatsViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateNavigationBarAppearance()
    }
    
}
