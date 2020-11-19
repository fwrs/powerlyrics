//
//  TableView.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

class TableView: UITableView {
    
    var refreshControlHandle: DefaultAction?
    
    @objc private func refreshControlPulled(_ sender: UIRefreshControl) {
        refreshControlHandle?()
    }
    
    var customRefreshControl: UIRefreshControl?
    
    var isRefreshing: Bool {
        get {
            customRefreshControl?.isRefreshing == true
        }
        set {
            if newValue {
                customRefreshControl?.beginRefreshing()
            } else {
                delay(0.5) { [weak self] in
                    self?.customRefreshControl?.endRefreshing()
                }
            }
        }
    }
    
    // MARK: - Public API
    
    @discardableResult func setRefreshControl(top: CGFloat = .zero, _ completion: @escaping DefaultAction) -> UIRefreshControl {
        if let control = customRefreshControl { return control }
        refreshControlHandle = completion
        let newControl = UIRefreshControl()
        newControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        customRefreshControl = newControl
        let refreshView = UIView(frame: CGRect(x: .zero, y: top, width: .zero, height: .zero))
        addSubview(refreshView)
        refreshView.addSubview(newControl)
        return newControl
    }
    
    @discardableResult func setRefreshControl(top: CGFloat = .zero) -> UIRefreshControl {
        setRefreshControl(top: top) { [weak self] in
            delay(.half) {
                self?.set(refreshing: false)
            }
        }
    }
    
    func unsetRefreshControl() {
        customRefreshControl?.removeFromSuperview()
        customRefreshControl = nil
    }
    
    func set(refreshing: Bool) {
        if refreshing {
            customRefreshControl?.beginRefreshing()
        } else {
            customRefreshControl?.endRefreshing()
        }
    }
    
    func register<T>(_: T.Type) {
        register(UINib(nibName: String(describing: T.self), bundle: nil), forCellReuseIdentifier: String(describing: T.self))
    }
    
    func dequeue<T>(_: T.Type, indexPath: IndexPath) -> T {
        dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as! T
    }
    
}
