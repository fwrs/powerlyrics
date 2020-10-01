//
//  HomeView.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import UIKit

class HomeViewController: ViewController, HomeScene {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet private weak var navBarLabel: UILabel!
    
    @IBOutlet private var navBarStackView: UIStackView!
    
    // MARK: - Instance properties
    
    var flowSample: DefaultAction?
    
    var viewModel: HomeViewModel!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupView()
    }
    
    // MARK: - Actions
    
    @IBAction private func addAccountPressed(_ sender: Any) {
        flowSample?()
    }
    
}

extension HomeViewController {
    
    // MARK: - View setup
    
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navBarStackView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.crop.circle.badge.plus"),
            style: .plain,
            target: self,
            action: #selector(addAccountPressed)
        )
    }

    func setupView() {}
    
}
