//
//  ImagePreviewController.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/3/20.
//

import UIKit

class ImagePreviewController: UIViewController {
    private let imageView = UIImageView()
    
    init?(_ image: UIImage?) {
        guard let image = image else { return nil }
        super.init(nibName: nil, bundle: nil)
        
        let ratio = image.size.height / image.size.width
        let width = UIScreen.main.bounds.width
        let newSize = CGSize(width: width, height: ratio * width)
        
        preferredContentSize = newSize
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = image
        view = imageView
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
