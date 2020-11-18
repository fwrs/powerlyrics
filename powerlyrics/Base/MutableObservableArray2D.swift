//
//  Showable.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/27/20.
//

import Bond
import ReactiveKit

extension MutableObservableArray2D where Value: TreeChangesetProtocol, Value.Collection: Array2DProtocol, SectionMetadata: Equatable, Item: Equatable {
    
    func set(_ items: [(SectionMetadata, [Item])]) {
        replace(with: Array2D(sectionsWithItems: items.filter { $0.1.nonEmpty }) as! Value.Collection, performDiff: true, areEqual: { lhs, rhs in
            lhs.section?.metadata == rhs.section?.metadata && lhs.item == rhs.item
        })
    }
    
}

extension MutableObservableArray2D where Value: TreeChangesetProtocol, Value.Collection: Array2DProtocol, SectionMetadata == (), Item: Equatable {
    
    func set(_ items: [(SectionMetadata, [Item])]) {
        replace(with: Array2D(sectionsWithItems: items.filter { $0.1.nonEmpty }) as! Value.Collection, performDiff: true, areEqual: { lhs, rhs in
            lhs.item == rhs.item
        })
    }
    
}
