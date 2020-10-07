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
