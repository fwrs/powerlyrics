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
    
    // MARK: - Public Api
    
    @discardableResult public func setRefreshControl(_ completion: DefaultAction?) -> UIRefreshControl {
        refreshControlHandle = completion
        let newControl = UIRefreshControl()
        newControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        refreshControl = newControl
        return newControl
    }
    
    public func set(refreshing: Bool) {
        if refreshing {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
}
