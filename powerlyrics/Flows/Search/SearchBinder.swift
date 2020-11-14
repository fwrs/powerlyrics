//
//  SearchBinder.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/3/20.
//

import Bond
import ReactiveKit
import UIKit

class SearchBinder<Changeset: SectionedDataSourceChangeset>: TableViewBinderDataSource<Changeset> where Changeset.Collection == Array2D<SearchSection, SearchCell> {
    
    init(albumTapAction: @escaping DefaultSpotifyAlbumAction) {
        super.init { (items, indexPath, uiTableView) in
            let element = items[childAt: indexPath]
            let tableView = uiTableView as! TableView
            switch element.item {
            case .song(let songCellViewModel):
                let cell = tableView.dequeue(SongCell.self, indexPath: indexPath)
                cell.configure(with: songCellViewModel)
                return cell
            case .albums(let albumsCellViewModel):
                let cell = tableView.dequeue(AlbumsCell.self, indexPath: indexPath)
                cell.configure(with: albumsCellViewModel)
                cell.didTapAlbum = albumTapAction
                return cell
            default:
                fatalError("Invalid cell")
            }
        }
    }
    
    @objc func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        changeset?.collection[sectionAt: section].metadata.localizedTitle
    }
    
}
