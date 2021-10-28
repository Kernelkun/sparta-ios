//
//  ArbPlaygroundMenuView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 26.10.2021.
//

import UIKit

class ArbPlaygroundMenuView: UIView {

    // MARK: - Private properties

    private let items: [ArbPlaygroundMenuItemView]

    // MARK: - Initializers

    init(items: [ArbPlaygroundMenuItemView]) {
        self.items = items
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = .secondaryBackground
        layer.cornerRadius = 13

        _ = UIStackView().then { stackView in

            stackView.axis = .vertical
            stackView.distribution = .equalSpacing
            stackView.spacing = 18
            stackView.alignment = .fill

            items.forEach { itemView in
                stackView.addArrangedSubview(itemView)
            }

            addSubview(stackView) {
                $0.width.equalTo(40)
                $0.left.right.equalToSuperview().inset(11)
                $0.top.bottom.equalToSuperview().inset(9)
            }
        }
    }
}
