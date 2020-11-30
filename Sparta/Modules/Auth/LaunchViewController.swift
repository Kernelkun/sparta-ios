//
//  LaunchViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 25.11.2020.
//

import UIKit
import NVActivityIndicatorView

class LaunchViewController: BaseViewController {

    // MARK: - Private accessors

    private var titleLabel: UILabel!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Private methods

    private func setupUI() {

        view.backgroundColor = .black

        loader.startAnimating()

        titleLabel = UILabel().then { label in

            label.text = "Sparta".uppercased()
            label.textColor = .primaryText
            label.font = .boldSystemFont(ofSize: 20)

            addSubview(label) {
                $0.centerX.equalToSuperview()
                $0.centerY.equalToSuperview().inset(20)
            }
        }
    }
}
