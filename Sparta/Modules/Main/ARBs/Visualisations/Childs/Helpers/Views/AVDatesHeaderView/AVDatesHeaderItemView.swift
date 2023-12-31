//
//  AVDatesHeaderItemView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.10.2021.
//

import UIKit

class AVDatesHeaderItemView: UIView {

    // MARK: - Private properties

    private var titleLabel: UILabel!
    private var subTitleLabel: UILabel!

    private let title: String
    private let subTitle: String

    // MARK: - Initializers

    init(title: String, subTitle: String) {
        self.title = title
        self.subTitle = subTitle
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Private methods

    private func setupUI() {
        titleLabel = UILabel().then { label in

            label.text = title
            label.textAlignment = .center
            label.textColor = .primaryText
            label.font = .main(weight: .regular, size: 10)
            label.numberOfLines = 3
        }

        subTitleLabel = UILabel().then { label in

            label.text = subTitle
            label.textAlignment = .center
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 10)
            label.numberOfLines = 0
        }

        _ = UIStackView().then { stackView in

            stackView.axis = .vertical
            stackView.distribution = .equalSpacing
            stackView.spacing = 2
            stackView.alignment = .fill

            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(subTitleLabel)

            addSubview(stackView) {
                $0.left.right.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
        }
    }
}
