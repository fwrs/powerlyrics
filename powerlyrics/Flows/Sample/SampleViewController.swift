//
//  SampleView.swift
//  powerlyrics
//
//  Created by Ilya Kulinkovich on 10/1/20.
//

import UIKit

class SampleViewController: ViewController, SampleScene {
    var flowSample: DefaultAction?
    
    var viewModel: SampleViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    @IBAction private func buttonPressed(_ sender: Any) {
        flowSample?()
    }
}

// MARK: - View setup
extension SampleViewController {
    func setupView() {
        title = "Test"

        view.backgroundColor = window.tintColor
    }
}
