//
//  TableView.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//

import UIKit

class TableView: UITableView {
    
    private var refreshControlHandle: DefaultAction?
    
    @objc private func refreshControlPulled(_ sender: UIRefreshControl) {
        refreshControlHandle?()
    }
    
    private var customRefreshControl: UIRefreshControl?
    
    // MARK: - Public Api
    
    @discardableResult public func setRefreshControl(top: CGFloat = 0, _ completion: @escaping DefaultAction) -> UIRefreshControl {
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
    
    @discardableResult public func setRefreshControl(top: CGFloat = 0) -> UIRefreshControl {
        setRefreshControl(top: top) { [self] in
            delay(0.5) {
                set(refreshing: false)
            }
        }
    }
    
    public func unsetRefreshControl() {
        customRefreshControl?.removeFromSuperview()
        customRefreshControl = nil
    }
    
    public func set(refreshing: Bool) {
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
