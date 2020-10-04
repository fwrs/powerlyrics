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
    
    @discardableResult public func setRefreshControl(_ completion: @escaping DefaultAction) -> UIRefreshControl {
        if let control = customRefreshControl { return control }
        refreshControlHandle = completion
        let newControl = UIRefreshControl()
        newControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        addSubview(newControl)
        customRefreshControl = newControl
        return newControl
    }
    
    @discardableResult public func setRefreshControl() -> UIRefreshControl {
        setRefreshControl { [self] in
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
    
}
