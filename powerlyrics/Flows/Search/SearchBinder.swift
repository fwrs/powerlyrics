//
//  SearchBinder.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/3/20.
//

import Bond
import ReactiveKit
import UIKit

class SearchBinder<Changeset: SectionedDataSourceChangeset>: TableViewBinderDataSource<Changeset> where Changeset.Collection == Array2D<SearchSection, SongCellViewModel> {

    @objc func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        changeset?.collection[sectionAt: section].metadata.localizedDescription
    }
    
}
