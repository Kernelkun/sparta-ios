//
//  ArbsVPlaygroundButton.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 01.12.2021.
//

import UIKit
import SpartaHelpers

class ArbsVPlaygroundButton: TappableButton {

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = .fip
        layer.cornerRadius = 6

        let sizeConfig = UIImage.SymbolConfiguration(pointSize: 17)
        let image = UIImage(systemName: "slider.horizontal.3")?
            .applyingSymbolConfiguration(sizeConfig)

        setImage(image, for: .normal)
        tintColor = .primaryText
    }
}
