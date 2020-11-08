//
//  Image.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/23/20.
//

import UIKit

enum SharedImage: Equatable {
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

    func populate(with newImage: SharedImage?, placeholder: UIImage? = nil) {
        tag = 0
        switch newImage {
        case .local(let localImage):
            image = localImage
            tag = 10
        case .external(let imageURL):
            kf.setImage(with: imageURL, placeholder: placeholder ?? UIImageView.placeholder, completionHandler: { [self] _ in
                tag = 10
            })
        case .none:
            image = UIImageView.placeholder
        }
    }
    
}
