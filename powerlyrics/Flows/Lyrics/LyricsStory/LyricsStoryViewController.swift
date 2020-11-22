//
//  LyricsStoryViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/21/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Haptica
import PanModal
import ReactiveKit

// MARK: - Constants

fileprivate extension Constants {
    
    static let viewOpacity: CGFloat = 0.7
    
}

// MARK: - LyricsStoryViewController

class LyricsStoryViewController: ViewController, LyricsStoryScene {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: TableView!
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var titleBackgroundView: UIVisualEffectView!
    
    @IBOutlet private weak var titleShadowView: UIView!
    
    // MARK: - Instance properties
    
    var viewModel: LyricsStoryViewModel!
    
    // MARK: - Flows
    
    var flowDismiss: DefaultAction?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupOutput()
        
        viewModel.loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        flowDismiss?()
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

extension LyricsStoryViewController {
    
    // MARK: - View

    func setupView() {
        
        tableView.register(LyricsStoryEmptyCell.self)
        tableView.register(LyricsStoryTopPaddingCell.self)
        tableView.register(LyricsStoryContentCell.self)
        
        tableView.delegate = self
        tableView.automaticallyAdjustsScrollIndicatorInsets = false
        
        panModalSetNeedsLayoutUpdate()
        updateNavigationBarAppearance()
        
        view.backgroundColor = view.backgroundColor?.withAlphaComponent(Constants.viewOpacity)
        
    }
    
    // MARK: - Output
    
    func setupOutput() {
        
        viewModel.items.bind(to: tableView) { items, indexPath, uiTableView in
            let tableView = uiTableView as! TableView
            let item = items[indexPath.row]
            switch item {
            case .empty:
                let cell = tableView.dequeue(LyricsStoryEmptyCell.self, indexPath: indexPath)
                cell.separatorInset = UIEdgeInsets().with { $0.left = tableView.bounds.width }
                cell.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                return cell
                
            case .topPadding:
                let cell = tableView.dequeue(LyricsStoryTopPaddingCell.self, indexPath: indexPath)
                cell.separatorInset = UIEdgeInsets().with { $0.left = tableView.bounds.width }
                cell.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                return cell
                
            case .content(let lyricsStoryContentCellViewMoedl):
                let cell = tableView.dequeue(LyricsStoryContentCell.self, indexPath: indexPath)
                cell.configure(with: lyricsStoryContentCellViewMoedl)
                cell.separatorInset = UIEdgeInsets().with { $0.left = tableView.bounds.width }
                cell.selectionStyle = .none
                return cell
            }
        }.dispose(in: disposeBag)
        
    }
    
}

// MARK: - PanModalPresentable

extension LyricsStoryViewController: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        tableView
    }
    
    var panModalBackgroundColor: UIColor {
        .clear
    }
    
    var cornerRadius: CGFloat {
        Constants.panModalCornerRadius
    }
    
    var isHapticFeedbackEnabled: Bool {
        false
    }
    
}

// MARK: - UITableViewDelegate

extension LyricsStoryViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateNavigationBarAppearance()
    }
    
}
