//
//  LCWebResultItemView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 09.02.2022.
//

import UIKit

class LCWebResultItemView: UIView {

    // MARK: - Private properties

    private let configurator: Configurator

    // MARK: - Initializers

    init(configurator: Configurator) {
        self.configurator = configurator
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Private methods

    private func setupUI() {

        let titleLabel = UILabel().then { label in

            label.attributedText = configurator.titleText
            label.numberOfLines = 0
        }

        let valueLabel = UILabel().then { label in

            label.attributedText = configurator.valueText
            label.numberOfLines = 0
        }

        _ = UIStackView().then { stackView in

            stackView.alignment = .center
            stackView.distribution = .equalSpacing
            stackView.spacing = 4
            stackView.axis = .vertical

            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(valueLabel)

            addSubview(stackView) {
                $0.edges.equalToSuperview()
            }
        }
    }

}

extension LCWebResultItemView {
    struct Configurator {
        let titleText: NSAttributedString
        let valueText: NSAttributedString
    }
}
