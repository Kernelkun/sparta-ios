//
//  StarButton.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 17.02.2021.
//

import UIKit
import SpartaHelpers

class StarButton: TappableButton {

    var isActive: Bool {
        didSet {
            updateUI()
        }
    }

    // MARK: - Initializers

    init() {
        isActive = false

        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("StarButton")
    }

    // MARK: - Private methods

    private func setupUI() {
        updateUI()
    }

    private func updateUI() {
        let image = UIImage(named: "ic_star")
        setBackgroundImage(image, for: .normal)
        tintColor = isActive ? .controlTintActive : .secondaryText
    }
}
