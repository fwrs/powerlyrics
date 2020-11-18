//
//  GenreMapGenreStatsViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/7/20.
//

import Haptica
import PanModal
import ReactiveKit
import Then
import UIKit

class GenreStatsViewController: ViewController, GenreStatsScene {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: TableView!
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var titleBackgroundView: UIVisualEffectView!
    
    @IBOutlet private weak var titleShadowView: UIView!
    
    // MARK: - Instance properties
    
    var viewModel: GenreStatsViewModel!
    
    private var lastSelectedIndexPath: IndexPath?
    
    var initial: Bool = true
    
    var navigationBarBackgroundHidden = true
    
    // MARK: - Flows
    
    var flowLyrics: ((SharedSong, UIImage?) -> Void)?
    
    var flowDismiss: DefaultAction?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if presentedViewController == nil {
            flowDismiss?()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !initial {
            viewModel.reload()
        }
        initial = false
    }
    
    // MARK: - Actions
    
}

extension GenreStatsViewController {
    
    // MARK: - Setup

    func setupView() {
        tableView.register(SongCell.self)
        tableView.register(GenreInfoCell.self)
        tableView.register(GenreEmptyCell.self)
        
        panModalSetNeedsLayoutUpdate()
    
        viewModel.items.observeNext { [self] _ in
            delay(0.01) {
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
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
                }
                return cell
            case .empty:
                let cell = tableView.dequeue(GenreEmptyCell.self, indexPath: indexPath)
                cell.separatorInset = .init(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
                cell.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                return cell
            }
        }
        tableView.delegate = self
        tableView.automaticallyAdjustsScrollIndicatorInsets = false
        
        tableView.reactive.selectedRowIndexPath.observeNext { [self] indexPath in
            tableView.deselectRow(at: indexPath, animated: true)
            lastSelectedIndexPath = indexPath
            Haptic.play(".")
            if case .song(let songCellViewModel) = viewModel.items[indexPath.row] {
                flowLyrics?(songCellViewModel.song, nil)
            }
        }.dispose(in: disposeBag)
        
        titleLabel.text = viewModel.genre.localizedName
        
        updateNavigationBarAppearance()
    }
    
    func updateNavigationBarAppearance() {
        if navigationBarBackgroundHidden && tableView.contentOffset.y < 10 {
            return
        }
        if !navigationBarBackgroundHidden && tableView.contentOffset.y >= 10 {
            return
        }
        navigationBarBackgroundHidden = tableView.contentOffset.y < 10
        UIView.transition(with: titleBackgroundView, duration: 0.3, options: .transitionCrossDissolve) { [self] in
            titleBackgroundView.isHidden = tableView.contentOffset.y < 10
        }
        UIView.transition(with: titleShadowView, duration: 0.3, options: .transitionCrossDissolve) { [self] in
            titleShadowView.isHidden = tableView.contentOffset.y < 10
        }
    }
    
}

extension GenreStatsViewController: TranslationAnimationView {
    
    var translationViews: [UIView] {
        guard let indexPath = lastSelectedIndexPath,
              let container = (tableView.cellForRow(at: indexPath) as? SongCell)?.songContainer else { return [] }
        return [container]
    }
    
    var translationInteractor: TranslationAnimationInteractor? { nil }
    
    var isSourcePanModal: Bool { true }
    
}

extension GenreStatsViewController: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        tableView
    }
    
    var panModalBackgroundColor: UIColor {
        .clear
    }
    
    var cornerRadius: CGFloat {
        30
    }
    
}

extension GenreStatsViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateNavigationBarAppearance()
    }
    
}
