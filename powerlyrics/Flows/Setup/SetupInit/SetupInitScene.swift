//
//  SetupInitScene.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/4/20.
//

import Foundation

protocol SetupInitScene: ViewController {
    var flowDismiss: DefaultAction? { get set }
    var flowOfflineSetup: DefaultAction? { get set }
}
