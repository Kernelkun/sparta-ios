//
//  BorderedButton.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 29.11.2020.
//

import UIKit

class BorderedButton: TappableButton {

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupUI()
    }

    // MARK: - Private methods

    private func setupUI() {

        // general

        backgroundColor = .mainButtonBackground
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .main(weight: .semibold, size: 17)

        // layer

        layer.masksToBounds = true
        layer.cornerRadius = 8
    }
}
