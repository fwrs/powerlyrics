//
//  ImagePreviewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/3/20.
//

import UIKit

class ImagePreviewController: UIViewController {
    private let imageView = UIImageView()
    
    init?(_ image: Shared.Image?, placeholder: UIImage? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        let width = UIScreen.main.bounds.width
        let newSize = CGSize(width: width, height: width)
        
        preferredContentSize = newSize
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.populate(with: image, placeholder: placeholder)
        view = imageView
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
