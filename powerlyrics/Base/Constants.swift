//
//  Constants.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 11/18/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import UIKit

// MARK: - Constants

enum Constants {
    
    // MARK: - Fonts
    
    static let titleFont = FontFamily.RobotoMono.semiBold.font(size: 17)
    
    // MARK: - Text
    
    static let ellipsisText = "..."
    static let commaText = ", "
    static let spaceText = " "
    static let periodText = "."
    static let emptyText = ""
    static let newline = "\n"
    static let newlineCharacter: Character = "\n"
    static let escapedNewline = "\\n"
    static let dash = "-"
    static let ampersand = "&"
    static let ampersandCharacter: Character = "&"
    static let question = "?"
    static let exclamation = "!"
    static let spotifySystemName = "spotify"
    static let geniusSystemName = "genius"
    static let startingParenthesis = "("
    static let startingParenthesisCharacter: Character = "("
    static let comma = ","
    static let commaCharacter: Character = ","
    static let ok = Strings.Shared.ok
    static let cancel = Strings.Shared.cancel
    static let englishPlural = "s"
    
    // MARK: - Spacing
    
    static let space2: CGFloat = 2
    static let space8: CGFloat = 8
    static let space10: CGFloat = 10
    static let space12: CGFloat = 12
    static let space16: CGFloat = 16
    static let space20: CGFloat = 20
    static let space24: CGFloat = 24
    static let space44: CGFloat = 44
    static let navigationBarHeight: CGFloat = 44
    
    // MARK: - Animations
    
    static let fastAnimationDuration = Double.pointThree / .two
    static let defaultAnimationDuration = Double.pointThree
    static let defaultAnimationDelay = Double.pointThree
    
    // MARK: - Album art
    
    static let albumArtShadowRadius: CGFloat = 6
    static let albumArtShadowOffset = CGSize(width: .zero, height: 3)
    static let albumArtShadowCornerRadius: CGFloat = 8
    static let albumArtShadowColor = UIColor.black
    
    // MARK: - Haptic
    
    static let tinyTap = "."
    static let successTaps = ".-O"
    
    // MARK: - Miscellaneous
    
    static let buttonThrottleTime = Double.pointThree
    static let defaultShadowOpacity = Float.pointThree
    
}
