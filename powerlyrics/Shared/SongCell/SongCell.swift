//
//  SongCell.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/2/20.
//

import UIKit

class SongCell: TableViewCell {
    
    @IBOutlet private weak var albumArtContainerView: UIView!
    
    @IBOutlet private weak var albumArtImageView: UIImageView!
    
    @IBOutlet private weak var songLabel: UILabel!
    
    @IBOutlet private weak var artistLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        albumArtContainerView.shadow(
            color: .black,
            radius: 6,
            offset: CGSize(width: 0, height: 3),
            opacity: 0.5,
            viewCornerRadius: 8,
            viewSquircle: true
        )
    }
    
    func configure(with viewModel: SongCellViewModel) {
        songLabel.text = viewModel.songName
        artistLabel.text = viewModel.artistName
        albumArtImageView.image = viewModel.albumArt
    }
    
}
