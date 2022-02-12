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
        backgroundColor = UIColor.neutral80

        _ = UIStackView().then { stackView in

            stackView.axis = .vertical
            stackView.distribution = .equalSpacing
            stackView.spacing = 16
            stackView.alignment = .fill

            for _ in 0..<4 {
                stackView.addArrangedSubview(LCWebHistoricalDataLineView())
            }

            addSubview(stackView) {
                $0.top.bottom.equalToSuperview().inset(16)
                $0.left.right.equalToSuperview()
            }
        }
    }
}
