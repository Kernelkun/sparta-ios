//
//  ResultKeyValueView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 24.01.2021.
//

import UIKit
import SpartaHelpers
import NetworkingModels

class ResultKeyValueView<T: Hashable>: UIView, Identifiable {

    var id: T

    // MARK: - UI

    private var keyLabel: UILabel!
    private var valueLabel: UILabel!

    // MARK: - Initializers

    init(id: T) {
        self.id = id

        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func apply(key: String, value: String, valueColor: UIColor) {
        keyLabel.text = key
        valueLabel.text = value
        valueLabel.textColor = valueColor
    }

    // MARK: - Private methods

    private func setupUI() {

        backgroundColor = UIColor.accountFieldBackground
        layer.cornerRadius = 4

        keyLabel = UILabel().then { label in

            label.font = .main(weight: .regular, size: 17)
            label.textColor = .accountMainText
            label.textAlignment = .center

            addSubview(label) {
                $0.left.equalToSuperview().offset(8)
                $0.centerY.equalToSuperview()
            }
        }

        valueLabel = UILabel().then { label in

            label.font = .main(weight: .regular, size: 17)
            label.textColor = .accountMainText
            label.textAlignment = .center

            addSubview(label) {
                $0.right.equalToSuperview().inset(8)
                $0.centerY.equalToSuperview()
            }
        }
    }
}
