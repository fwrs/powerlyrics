//
//  Router.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//  Copyright © 2020 Ilya Kulinkovich. All rights reserved.
//

import PanModal
import UIKit

class Router: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureNavigationbar()
    }
    
    func configureUI() {
        view.backgroundColor = UIColor.systemBackground
    }
    
    func configureNavigationbar() {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            .font: Constants.titleFont
        ]
        appearance.largeTitleTextAttributes = appearance.titleTextAttributes
        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.prefersLargeTitles = false
    }
    
    func push(_ viewController: UIViewController?, animated: Bool = true) {
        pushViewController(viewController!, animated: animated)
    }
    
}

extension Router: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        (topViewController as! PanModalPresentable).panScrollable
    }
    
    var panModalBackgroundColor: UIColor {
        (topViewController as! PanModalPresentable).panModalBackgroundColor
    }
    
    var cornerRadius: CGFloat {
        (topViewController as! PanModalPresentable).cornerRadius
    }
    
    var shortFormHeight: PanModalHeight {
        (topViewController as! PanModalPresentable).shortFormHeight
    }
    
    var longFormHeight: PanModalHeight {
        (topViewController as! PanModalPresentable).longFormHeight
    }
    
    var anchorModalToLongForm: Bool {
        (topViewController as! PanModalPresentable).anchorModalToLongForm
    }
    
}
