//
//  LyricsSectionCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/24/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

// MARK: - Constants

extension Constants {
    
    static let contextMenuFadeOutDelay: TimeInterval = 0.8
    
    static let paragraphStyle = NSMutableParagraphStyle().with {
        $0.lineSpacing = 4
    }
    
}

// MARK: - LyricsSectionCell

class LyricsSectionCell: TableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var nameLabel: UILabel!
    
    @IBOutlet private weak var contentsLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let interaction = UIContextMenuInteraction(delegate: self)
        addInteraction(interaction)
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: LyricsSectionCellViewModel) {
        if let sectionName = viewModel.section.name?.dropFirst().string.uppercased() {
            nameLabel.text = sectionName.last == Constants.sectionEnd ? sectionName.dropLast().string : sectionName
        } else {
            nameLabel.text = nil
        }
        
        nameLabel.isHidden = viewModel.section.name == nil

        let attrString = NSMutableAttributedString(
            string: viewModel.section.contents.joined(separator: String(Constants.newline)).typographized
        )
        
        attrString.addAttribute(
            .paragraphStyle,
            value: Constants.paragraphStyle,
            range: NSRange(location: .zero, length: attrString.length)
        )

        contentsLabel.attributedText = attrString
    }
    
}

// MARK: - UIContextMenuInteractionDelegate

extension LyricsSectionCell: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        let copyElement = UIAction(
            title: Constants.copy.title,
            image: Constants.copy.icon
        ) { [self] _ in
            let text = contentsLabel.text
            UIPasteboard.general.string = text
        }
        
        UIView.animate(withDuration: .pointOne, delay: .pointOne) { [self] in
            backgroundColor = .systemBackground
        }
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { suggestedActions in
                UIMenu(children: suggestedActions + [copyElement])
            }
        )
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        UIView.animate(
            withDuration: .oneHalfth * .pointOne,
            delay: Constants.contextMenuFadeOutDelay
        ) { [self] in
            backgroundColor = .clear
        }
    }
    
}
