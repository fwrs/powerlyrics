//
//  Image.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/23/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import Kingfisher
import UIKit

enum SharedImage: Equatable, Hashable {
    case local(UIImage)
    case external(URL)
}

extension SharedImage: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case url
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let url = try values.decode(URL.self, forKey: .url)
        self = .external(url)
    }
    
    func encode(to encoder: Encoder) throws {
        fatalError("Not supported")
    }
    
}

extension UIImageView {
    
    static var placeholder: UIImage {
        UIImage.from(color: .tertiarySystemBackground)
    }
    
    var loaded: Bool {
        tag == 10
    }

    func populate(with newImage: SharedImage?, placeholder: UIImage? = nil, result: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) {
        tag = 0
        switch newImage {
        case .local(let localImage):
            image = localImage
            tag = 10
        case .external(let imageURL):
            kf.setImage(with: imageURL, placeholder: placeholder ?? UIImageView.placeholder, completionHandler: { [self] res in
                tag = 10
                result?(res)
            })
        case .none:
            image = UIImageView.placeholder
        }
    }
    
}
