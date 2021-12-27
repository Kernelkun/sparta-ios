//
//  AACLightsSetView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.12.2021.
//

import UIKit

class AACLightsSetView: UIView {

    // MARK: - Private properties

    private var contentView: UIView!

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

        _ = UIStackView().then { stackView in

            stackView.axis = .vertical
            stackView.distribution = .fill
            stackView.spacing = APPCUIConstants.priceItemsLineSpace
            stackView.alignment = .fill

            for _ in 0..<3 {
                let view = AACLightView().then {
                    $0.snp.makeConstraints {
                        $0.height.equalTo(50)
                    }
                }
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

