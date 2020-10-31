//
//  ProfileBinder.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/31/20.
//

import Bond
import ReactiveKit
import UIKit

enum ProfileCell: Equatable {
    case stats(StatsCellViewModel)
    case action(ActionCellViewModel)
    case build(BuildCellViewModel)
}

class ProfileBinder<Changeset: SectionedDataSourceChangeset>: TableViewBinderDataSource<Changeset> where Changeset.Collection == Array2D<(), ProfileCell> {

    override init() {
        super.init { (items, indexPath, uiTableView) in
            let element = items[childAt: indexPath]
            let tableView = uiTableView as! TableView
            switch element.item {
            case .stats(let statsCellViewModel):
                let cell = tableView.dequeue(StatsCell.self, indexPath: indexPath)
                cell.configure(with: statsCellViewModel)
                cell.selectionStyle = .none
                cell.isUserInteractionEnabled = false
                return cell
            case .action(let actionCellViewModel):
                let cell = tableView.dequeue(ActionCell.self, indexPath: indexPath)
                cell.configure(with: actionCellViewModel)
                return cell
            case .build(let buildCellViewModel):
                let cell = tableView.dequeue(BuildCell.self, indexPath: indexPath)
                cell.configure(with: buildCellViewModel)
                return cell
            default:
                fatalError("Invalid cell")
            }
        }
    }

}
