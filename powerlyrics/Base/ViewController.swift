//
//  ViewController+Ext.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Haptica
import ReactiveKit
import UIKit

public class ViewController: UIViewController, UITabBarControllerDelegate {
    
    let disposeBag = DisposeBag()
    
    deinit {
        disposeBag.dispose()
    }
    
    var window: UIWindow {
        (UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate).window!
    }
    
    var safeAreaInsets: UIEdgeInsets {
        UIApplication.shared.windows.first { $0.isKeyWindow }!.safeAreaInsets
    }
    
    public var tabBarCanScrollToTop: Bool { true }
    
    public var prefersNavigationBarHidden: Bool { false }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if safeValue(forKey: "searchController") as? UISearchController != nil {
            UIView.performWithoutAnimation {
                navigationItem.hidesSearchBarWhenScrolling = false
            }
        }
        
        navigationController?.setNavigationBarHidden(prefersNavigationBarHidden, animated: animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        if tabBarCanScrollToTop {
            tabBarController?.delegate = self
        }
        
        if safeValue(forKey: "searchController") as? UISearchController != nil {
            UIView.performWithoutAnimation {
                navigationItem.hidesSearchBarWhenScrolling = true
            }
        }
    }
    
    public func scrollToTop() {
        scrollTableViewToTop()
        scrollCollectionViewToTop()
    }
    
    public func scrollTableViewToTop() {
        if let tableView = safeValue(forKey: "tableView") as? TableView {
            tableView.setContentOffset(
                CGPoint(
                    x: .zero,
                    y: -tableView.adjustedContentInset.top
                ),
                animated: true
            )
        }
    }
    
    public func scrollCollectionViewToTop() {
        if let collectionView = safeValue(forKey: "collectionView") as? UICollectionView {
            collectionView.setContentOffset(
                CGPoint(
                    x: -collectionView.adjustedContentInset.left,
                    y: -collectionView.adjustedContentInset.top
                ),
                animated: true
            )
        }
    }
    
    private func handleTabItemDoubleTap() {
        if let searchController = safeValue(forKey: "searchController") as? UISearchController {
            delay(0.1) {
                let shouldScrollToTop = !searchController.isActive
                searchController.searchBar.becomeFirstResponder()
                guard shouldScrollToTop else { return }
                delay(0.05) { [self] in
                    scrollToTop()
                }
            }
        } else {
            scrollToTop()
        }
    }
    
    private static var index: Int = 0
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if ViewController.index == tabBarController.selectedIndex {
            handleTabItemDoubleTap()
        }
        ViewController.index = tabBarController.selectedIndex
    }
    
}
