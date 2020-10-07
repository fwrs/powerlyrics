//
//  HomeScene.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import Foundation

protocol HomeScene: ViewController {
    var flowLyrics: DefaultSongAction? { get set }
    var flowSetup: DefaultSetupModeAction? { get set }
}
