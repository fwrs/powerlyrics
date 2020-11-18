//
//  EmptyView.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 15.11.20.
//

import UIKit

class EmptyView: UIView {

    @IBOutlet private weak var moonImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        moonImageView.image = moonImageView.image?.withTintColor(.label, renderingMode: .alwaysOriginal)
    }
    
}
