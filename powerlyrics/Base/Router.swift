//
//  Router.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

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
        
    }
    
    func push(_ viewController: UIViewController?, animated: Bool) {
        pushViewController(viewController!, animated: animated)
    }
    
}
