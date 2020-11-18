//
//  ViewController+Ext.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Haptica
import ReactiveKit
import UIKit

class ViewController: UIViewController, UITabBarControllerDelegate {
    
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
    
    var tabBarCanScrollToTop: Bool { true }
    
    var prefersNavigationBarHidden: Bool { false }
    
    private var noInternetView: NoInternetView?
    
    private var emptyView: EmptyView?
    
    private var isNoInternetViewVisible = false
    
    private var isEmptyViewVisible = false
    
    func setNoInternetView(isVisible: Bool, onTapRefresh: @escaping DefaultAction) {
        if isVisible {
            if isNoInternetViewVisible { return }
            isNoInternetViewVisible = true
            if let view = noInternetView {
                UIView.animate(withDuration: 0.3) {
                    view.alpha = 1
                }
                return
            }
            noInternetView?.layer.removeAllAnimations()
            let newNoInternetView = NoInternetView.loadFromNib()
            newNoInternetView.onRefresh = onTapRefresh
            view.addSubview(newNoInternetView)
            view.bringSubviewToFront(newNoInternetView)
            NSLayoutConstraint.activate([
                newNoInternetView.topAnchor.constraint(equalTo: view.topAnchor),
                newNoInternetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                newNoInternetView.leftAnchor.constraint(equalTo: view.leftAnchor),
                newNoInternetView.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
            noInternetView = newNoInternetView
            newNoInternetView.alpha = 0
            UIView.animate(withDuration: 0.3) {
                newNoInternetView.alpha = 1
            }
        } else {
            if !isNoInternetViewVisible { return }
            isNoInternetViewVisible = false
            noInternetView?.alpha = 1
            UIView.animate(withDuration: 0.3) { [self] in
                noInternetView?.alpha = 0
            } completion: { [self] _ in
                if !isNoInternetViewVisible {
                    noInternetView?.removeFromSuperview()
                    noInternetView = nil
                }
            }
        }
    }
    
    func setEmptyView(isVisible: Bool) {
        if isVisible {
            if isEmptyViewVisible { return }
            isEmptyViewVisible = true
            if let view = emptyView {
                UIView.animate(withDuration: 0.3) {
                    view.alpha = 1
                }
                return
            }
            let newEmptyView = EmptyView.loadFromNib()
            view.addSubview(newEmptyView)
            view.bringSubviewToFront(newEmptyView)
            NSLayoutConstraint.activate([
                newEmptyView.topAnchor.constraint(equalTo: view.topAnchor),
                newEmptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                newEmptyView.leftAnchor.constraint(equalTo: view.leftAnchor),
                newEmptyView.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
            emptyView = newEmptyView
            newEmptyView.alpha = 0
            UIView.animate(withDuration: 0.3) {
                newEmptyView.alpha = 1
            }
        } else {
            if !isEmptyViewVisible { return }
            isEmptyViewVisible = false
            emptyView?.alpha = 1
            UIView.animate(withDuration: 0.3) { [self] in
                emptyView?.alpha = 0
            } completion: { [self] _ in
                if !isEmptyViewVisible {
                    emptyView?.removeFromSuperview()
                    emptyView = nil
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // to be localized
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if safeValue(forKey: "searchController") as? UISearchController != nil {
            UIView.performWithoutAnimation {
                navigationItem.hidesSearchBarWhenScrolling = false
            }
        }
        
        navigationController?.setNavigationBarHidden(prefersNavigationBarHidden, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    func scrollToTop() {
        scrollTableViewToTop()
        scrollCollectionViewToTop()
    }
    
    func scrollTableViewToTop() {
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
    
    func scrollCollectionViewToTop() {
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
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if ViewController.index == tabBarController.selectedIndex {
            handleTabItemDoubleTap()
        }
        ViewController.index = tabBarController.selectedIndex
    }
    
}

@objc extension NSObject {
    
    // MARK: - Keyboard
    
    open func addKeyboardWillShowNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    open func addKeyboardDidShowNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    open func addKeyboardWillHideNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    open func addKeyboardDidHideNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    open func addKeyboardWillUpdateNotification() {
        addKeyboardWillShowNotification()
        addKeyboardWillHideNotification()
    }
    
    open func addKeyboardDidUpdateNotification() {
        addKeyboardDidShowNotification()
        addKeyboardDidHideNotification()
    }
    
    open func removeKeyboardWillShowNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    open func removeKeyboardDidShowNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    open func removeKeyboardWillHideNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    open func removeKeyboardDidHideNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    open func keyboardDidShow(notification: Notification) {
        guard let nInfo = notification.userInfo as? [String: Any], let value = nInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        keyboardDidShow(frame: value.cgRectValue)
        keyboardDidUpdate(frame: value.cgRectValue)
    }
    
    open func keyboardWillShow(notification: Notification) {
        guard let nInfo = notification.userInfo as? [String: Any], let value = nInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        keyboardWillShow(frame: value.cgRectValue)
        keyboardWillUpdate(frame: value.cgRectValue)
    }
    
    open func keyboardWillHide(notification: Notification) {
        guard let nInfo = notification.userInfo as? [String: Any], let value = nInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        keyboardWillHide(frame: value.cgRectValue)
        keyboardWillUpdate(frame: .zero)
    }
    
    open func keyboardDidHide(notification: Notification) {
        guard let nInfo = notification.userInfo as? [String: Any], let value = nInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        keyboardDidHide(frame: value.cgRectValue)
        keyboardDidUpdate(frame: .zero)
    }
    
    open func keyboardWillShow(frame: CGRect) {
        
    }
    
    open func keyboardDidShow(frame: CGRect) {
        
    }
    
    open func keyboardWillHide(frame: CGRect) {
        
    }
    
    open func keyboardDidHide(frame: CGRect) {
        
    }
    
    open func keyboardWillUpdate(frame: CGRect) {
        
    }
    
    open func keyboardDidUpdate(frame: CGRect) {
        
    }
    
}
