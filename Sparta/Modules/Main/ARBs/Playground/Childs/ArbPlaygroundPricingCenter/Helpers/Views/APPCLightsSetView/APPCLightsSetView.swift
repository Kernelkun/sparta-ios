//
//  APPCLightsSetView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.10.2021.
//

import UIKit

class APPCLightsSetView: UIView {

    // MARK: - Private properties

    private var contentView: UIView!

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setupUI() {

        _ = UIStackView().then { stackView in

            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = APPCUIConstants.priceItemSpace
            stackView.alignment = .fill

            for _ in 0..<6 {
                let view = APPCLightView()
                stackView.addArrangedSubview(view)
            }

            addSubview(stackView) {
                $0.edges.equalToSuperview()
            }
        }
    }

    private func updateUI() {

    }
}
