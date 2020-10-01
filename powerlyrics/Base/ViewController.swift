//
//  ViewController+Ext.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import UIKit

public class ViewController: UIViewController {
    
    var window: UIWindow {
        (UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate).window!
    }
    
}
