//
//  LCWebHistoricalDataView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 09.02.2022.
//

import UIKit

class LCWebHistoricalDataView: UIView {

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
        layer.cornerRadius = 10
        backgroundColor = UIColor.accountFieldBackground

        let titleLabel = UILabel().then { label in

            label.text = "Historical data"
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 16)
            label.numberOfLines = 0

            addSubview(label) {
                $0.top.equalToSuperview().offset(12)
                $0.left.equalToSuperview().offset(16)
            }
        }

        _ = UIStackView().then { stackView in

            stackView.axis = .vertical
            stackView.distribution = .equalSpacing
            stackView.spacing = 16
            stackView.alignment = .fill

            for _ in 0..<4 {
                stackView.addArrangedSubview(LCWebHistoricalDataItemView())
            }

            addSubview(stackView) {
                $0.top.equalTo(titleLabel.snp.bottom).offset(16)
                $0.left.right.equalToSuperview().inset(16)
                $0.bottom.equalToSuperview().inset(16)
            }
        }
    }
}
