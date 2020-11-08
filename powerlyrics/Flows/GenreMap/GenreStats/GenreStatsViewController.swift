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
    
    // MARK: - Instance properties
    
    var viewModel: GenreStatsViewModel!
    
    private var lastSelectedIndexPath: IndexPath?
    
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
    
    // MARK: - Actions
    
}

extension GenreStatsViewController {
    
    // MARK: - Setup

    func setupView() {
        tableView.register(SongCell.self)
        tableView.register(GenreInfoCell.self)
        
        viewModel.items.bind(to: tableView) { items, indexPath, uiTableView in
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
                }
                return cell
            }
        }
        tableView.delegate = self
        tableView.automaticallyAdjustsScrollIndicatorInsets = false
        
        tableView.reactive.selectedRowIndexPath.observeNext { [self] indexPath in
            tableView.deselectRow(at: indexPath, animated: true)
            lastSelectedIndexPath = indexPath
            if case .song(let songCellViewModel) = viewModel.items[indexPath.row] {
                flowLyrics?(songCellViewModel.song, nil)
            }
        }.dispose(in: disposeBag)
        
        updateNavigationBarAppearance()
    }
    
    func updateNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        if tableView.contentOffset.y < 1 {
            appearance.configureWithTransparentBackground()
        } else {
            appearance.configureWithDefaultBackground()
        }
        appearance.titleTextAttributes = [
            .font: FontFamily.RobotoMono.semiBold.font(size: 17)
        ]
        navigationItem.standardAppearance = appearance
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
    
    var shortFormHeight: PanModalHeight {
        .maxHeightWithTopInset(300)
    }
    
}

extension GenreStatsViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateNavigationBarAppearance()
    }
    
}
