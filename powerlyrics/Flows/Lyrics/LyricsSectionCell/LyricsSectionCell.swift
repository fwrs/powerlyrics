//
//  LyricsSectionCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/24/20.
//

import UIKit

class LyricsSectionCell: TableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    
    @IBOutlet private weak var contentsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let interaction = UIContextMenuInteraction(delegate: self)
        addInteraction(interaction)
    }
    
    func configure(with viewModel: LyricsSectionCellViewModel) {
        nameLabel.text = viewModel.section.name?.dropFirst().dropLast().string.uppercased()
        nameLabel.isHidden = viewModel.section.name == nil
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4

        let attrString = NSMutableAttributedString(string: viewModel.section.contents.joined(separator: "\n").typographized)
        attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attrString.length))

        contentsLabel.attributedText = attrString
    }
    
}

extension LyricsSectionCell: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        let copyElement = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in }
        UIView.animate(withDuration: 0.1, delay: 0.1) { [self] in
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
        UIView.animate(withDuration: 0.15, delay: 0.8) { [self] in
            backgroundColor = .clear
        }
    }
    
}