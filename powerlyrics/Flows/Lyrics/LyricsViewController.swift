//
//  LyricsViewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/3/20.
//

import Bond
import ReactiveKit
import UIKit

class LyricsViewController: ViewController, LyricsScene {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var songView: UIView!
    
    @IBOutlet private weak var albumArtContainerView: UIView!
    
    @IBOutlet private weak var albumArtImageView: UIImageView!
    
    @IBOutlet private weak var songLabel: UILabel!
    
    @IBOutlet private weak var artistLabel: UILabel!
    
    // MARK: - Instance properties

    var viewModel: LyricsViewModel!
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    
    var isInteractiveDismissal: Bool = true
    
    var swipeInteractionController: TranslationAnimationInteractor?
    
    // MARK: - Flows
    
    var flowDismiss: DefaultAction?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupObservers()
    }
    
    // MARK: - Actions
    
//    @objc func handleDismiss(_ sender: UIPanGestureRecognizer) {
//        switch sender.state {
//        case .changed:
//            viewTranslation = sender.translation(in: view)
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [self] in
//                navigationController?.view.transform = CGAffineTransform(translationX: self.viewTranslation.x, y: 0)
//            })
//        case .ended:
//            if viewTranslation.x < 50 {
//                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [self] in
//                    navigationController?.view.transform = .identity
//                })
//            } else {
//                dismiss(animated: true, completion: nil)
//                isInteractiveDismissal = false
//            }
//        default:
//            break
//        }
//    }
    
}

extension LyricsViewController {
    
    // MARK: - Setup

    func setupView() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
            .font: FontFamily.RobotoMono.semiBold.font(size: 17)
        ]
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        navigationItem.leftBarButtonItem?.reactive.tap.observeNext { [self] _ in
            flowDismiss?()
        }.dispose(in: disposeBag)
        
        navigationItem.leftBarButtonItem?.image = navigationItem.leftBarButtonItem?.image?
            .withTintColor(UIColor.grayButtonColor, renderingMode: .alwaysOriginal)
        
        albumArtContainerView.shadow(
            color: .black,
            radius: 6,
            offset: CGSize(width: .zero, height: 3),
            opacity: 0.5,
            viewCornerRadius: 8,
            viewSquircle: true
        )
        
        tableView.contentInset = UIEdgeInsets(top: 220 - safeAreaInsets.top, left: .zero, bottom: .zero, right: .zero)
        
//        navigationController?.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        
        swipeInteractionController = TranslationAnimationInteractor(viewController: self)
    }
    
    func setupObservers() {
        viewModel.song.observeNext { [self] song in
            songLabel.text = song.name
            artistLabel.text = song.artistName
            
            if let albumArt = song.albumArt {
                albumArtImageView.image = albumArt
            } else {
                albumArtImageView.image = UIImage.from(color: .tertiarySystemBackground)
            }
        }.dispose(in: disposeBag)
    }
    
}

extension LyricsViewController: TranslationAnimationView {
    
    var translationViews: [UIView] {
        [songView]
    }
    
    var interactionController: TranslationAnimationInteractor? {
        swipeInteractionController
    }
    
}
