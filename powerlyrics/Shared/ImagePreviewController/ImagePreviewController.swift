//
//  ImagePreviewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/3/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

class ImagePreviewController: UIViewController {
    
    let imageView = UIImageView()
    
    init?(_ image: SharedImage?, placeholder: UIImage? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        let width = UIScreen.main.bounds.width
        let newSize = CGSize(width: width, height: width)
        
        preferredContentSize = newSize
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = placeholder
        
        if image != nil || placeholder == nil {
            imageView.populate(with: image, placeholder: placeholder)
        } else if let placeholder = placeholder {
            imageView.populate(with: .local(placeholder))
        }
        
        view = imageView
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
