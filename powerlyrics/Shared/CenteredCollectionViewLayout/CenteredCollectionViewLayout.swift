//
//  CenteredCollectionViewLayout.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/3/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

class CenteredCollectionViewLayout: UICollectionViewFlowLayout {
    
    required init(
        minimumInteritemSpacing: CGFloat = .zero,
        minimumLineSpacing: CGFloat = .zero,
        sectionInset: UIEdgeInsets = .zero
    ) {
        super.init()
        
        estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.minimumLineSpacing = minimumLineSpacing
        self.sectionInset = sectionInset
        sectionInsetReference = .fromSafeArea
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        self.minimumInteritemSpacing = 13
        self.minimumLineSpacing = 14
        self.sectionInset = .zero
        sectionInsetReference = .fromSafeArea
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)!.map { $0.copy() as! UICollectionViewLayoutAttributes }
        guard scrollDirection == .vertical else { return layoutAttributes }
        
        let cellAttributes = layoutAttributes.filter({ $0.representedElementCategory == .cell })
        
        for (_, attributes) in Dictionary(grouping: cellAttributes, by: { ($0.center.y / 10).rounded(.up) * 10 }) {
            let cellsTotalWidth = attributes.reduce(CGFloat.zero) { (partialWidth, attribute) -> CGFloat in
                partialWidth + attribute.size.width
            }
            
            let totalInset = collectionView!.safeAreaLayoutGuide.layoutFrame.width - cellsTotalWidth - sectionInset.left - sectionInset.right - minimumInteritemSpacing * CGFloat(attributes.count - .one)
            var leftInset = (totalInset / .two * 10).rounded(.down) / 10 + sectionInset.left
            
            for attribute in attributes {
                attribute.frame.origin.x = leftInset
                leftInset = attribute.frame.maxX + minimumInteritemSpacing
            }
        }
        
        return layoutAttributes
    }
    
}
