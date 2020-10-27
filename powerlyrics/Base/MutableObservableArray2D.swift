//
//  Showable.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/27/20.
//

import Bond
import ReactiveKit

extension MutableObservableArray2D where Value: TreeChangesetProtocol, Value.Collection: Array2DProtocol, SectionMetadata: Hashable {
    
    func ensure(section: SectionMetadata, contents: Value.Collection.Item?) {
        
        if let index = (collection as! Array2D<Value.Collection.SectionMetadata, Value.Collection.Item>).sections.firstIndex(where: { $0.metadata == section }) {
            if let item = contents {
                self[sectionAt: index].items = [item]
            } else {
                removeSection(at: index)
            }
        } else if let item = contents {
            batchUpdate { array in
                array.insert(section: section, at: (collection as! Array2D<Value.Collection.SectionMetadata, Value.Collection.Item>).sections.count)
                array.appendItem(item, toSectionAt: (collection as! Array2D<Value.Collection.SectionMetadata, Value.Collection.Item>).sections.count)
            }
        }
        
    }
    
    func ensure(section: SectionMetadata, contents: [Value.Collection.Item]) {
        
        if let index = (collection as! Array2D<Value.Collection.SectionMetadata, Value.Collection.Item>).sections.firstIndex(where: { $0.metadata == section }) {
            if !contents.isEmpty {
                self[sectionAt: index].items = contents
            } else {
                removeSection(at: index)
            }
        } else if !contents.isEmpty {
            batchUpdate { array in
                array.insert(section: section, at: (collection as! Array2D<Value.Collection.SectionMetadata, Value.Collection.Item>).sections.count)
                for item in contents {
                    array.appendItem(item, toSectionAt: (collection as! Array2D<Value.Collection.SectionMetadata, Value.Collection.Item>).sections.count)
                }
            }
        }
        
    }
    
    // swiftlint:disable first_where
    func ensureOrder(_ sections: [SectionMetadata]) {
        var desiredPositions = [SectionMetadata: Int]()
        
        for (index, section) in (collection as! Array2D<Value.Collection.SectionMetadata, Value.Collection.Item>).sections.enumerated() {
            if sections.filter({ item in (collection as! Array2D<Value.Collection.SectionMetadata, Value.Collection.Item>).sections.contains { item == $0.metadata } }).firstIndex(where: { $0 == section.metadata }) != nil {
            } else {
                removeSection(at: index)
            }
        }
        
        for section in (collection as! Array2D<Value.Collection.SectionMetadata, Value.Collection.Item>).sections {
            if let newIndex = sections.filter({ item in (collection as! Array2D<Value.Collection.SectionMetadata, Value.Collection.Item>).sections.contains { item == $0.metadata } }).firstIndex(where: { $0 == section.metadata }) {
                desiredPositions[section.metadata] = newIndex
            }
        }
        
        for position in desiredPositions {
            if let index = (collection as! Array2D<Value.Collection.SectionMetadata, Value.Collection.Item>).sections.firstIndex(where: { $0.metadata == position.key }) {
                moveSection(from: index, to: position.value)
            }
        }
    }
    
}
