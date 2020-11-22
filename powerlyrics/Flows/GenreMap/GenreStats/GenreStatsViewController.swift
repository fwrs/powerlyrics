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

// MARK: - Constants

extension Constants {
    
    static let panModalCornerRadius: CGFloat = 30
    static let navigationBarBlurThreshold: CGFloat = 10
    
}

fileprivate extension Constants {
    
    static let tinyDelay = 0.01
    
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
        if (titleBackgroundView.isHidden && tableView.contentOffset.y < Constants.navigationBarBlurThreshold) ||
            (!titleBackgroundView.isHidden && tableView.contentOffset.y >= Constants.navigationBarBlurThreshold) {
            return
        }
        UIView.fadeUpdate(titleBackgroundView, duration: Constants.fastAnimationDuration) { [weak self] in
            guard let self = self else { return }
            self.titleBackgroundView.isHidden = self.tableView.contentOffset.y <= Constants.navigationBarBlurThreshold
        }
        UIView.fadeUpdate(titleShadowView, duration: Constants.fastAnimationDuration) { [weak self] in
            guard let self = self else { return }
            self.titleShadowView.isHidden = self.tableView.contentOffset.y <= Constants.navigationBarBlurThreshold
        }
    }
    
}

// MARK: - Setup

extension GenreStatsViewController {
    
    // MARK: - View

    func setupView() {
        
        tableView.register(GenreStatsEmptyCell.self)
        tableView.register(GenreStatsInfoCell.self)
        tableView.register(SongCell.self)
        
        tableView.delegate = self
        tableView.automaticallyAdjustsScrollIndicatorInsets = false
        
        titleLabel.text = viewModel.genre.localizedName
        
        panModalSetNeedsLayoutUpdate()
        updateNavigationBarAppearance()
        
    }
    
    // MARK: - Input
    
    func setupInput() {
    
        tableView.reactive.selectedRowIndexPath.observeNext { [weak self] indexPath in
            self?.tableView.deselectRow(at: indexPath, animated: true)
            self?.lastSelectedIndexPath = indexPath
            Haptic.play(Constants.tinyTap)
            if case .song(let songCellViewModel, _) = self?.viewModel.items[indexPath.row] {
                self?.flowLyrics?(songCellViewModel.song, nil)
            }
        }.dispose(in: disposeBag)
        
    }
    
    // MARK: - Output
    
    func setupOutput() {
        
        viewModel.items.bind(to: tableView) { items, indexPath, uiTableView in
            let tableView = uiTableView as! TableView
            let item = items[indexPath.row]
            switch item {
            case .empty:
                let cell = tableView.dequeue(GenreStatsEmptyCell.self, indexPath: indexPath)
                cell.separatorInset = UIEdgeInsets().with { $0.left = tableView.bounds.width }
                cell.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                return cell
                
            case .genreInfo(let genreStatsInfoCellViewModel):
                let cell = tableView.dequeue(GenreStatsInfoCell.self, indexPath: indexPath)
                cell.configure(with: genreStatsInfoCellViewModel)
                cell.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                cell.separatorInset = .zero
                return cell
                
            case .song(let songCellViewModel, let last):
                let cell = tableView.dequeue(SongCell.self, indexPath: indexPath)
                cell.configure(with: songCellViewModel)
                if last {
                    cell.separatorInset = .zero
                } else {
                    cell.separatorInset = UIEdgeInsets().with { $0.left = Constants.space16 }
                }
                return cell
            }
        }.dispose(in: disposeBag)
        
        viewModel.items.observeNext { [weak self] _ in
            delay(Constants.tinyDelay) {
                self?.panModalSetNeedsLayoutUpdate()
                if self?.viewModel.items.collection.filter({ $0 != .empty }).isEmpty == true || self?.initialLoad == true {
                    self?.panModalTransition(to: .shortForm)
                }
            }
        }.dispose(in: disposeBag)
        
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
