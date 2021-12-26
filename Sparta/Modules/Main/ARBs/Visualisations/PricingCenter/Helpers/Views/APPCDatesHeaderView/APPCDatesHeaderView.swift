//
//  APPCDatesHeaderView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.10.2021.
//

import UIKit

class APPCDatesHeaderView: UIView {

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

            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = APPCUIConstants.priceItemSpace
            stackView.alignment = .fill

            for _ in 0..<6 {
                let view = APPCDatesHeaderItemView(title: "Jul 21", subTitle: "cpg")
                stackView.addArrangedSubview(view)
            }

            addSubview(stackView) {
                $0.left.equalToSuperview().offset(APPCUIConstants.leftMenuWidth)
                $0.top.right.bottom.equalToSuperview()
                $0.height.equalTo(58)
            }
        }
    }
}
