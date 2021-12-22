//
//  APPCIdentifierView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.10.2021.
//

import UIKit

class APPCIdentifierView: UIView {

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
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        layer.cornerRadius = 5

        titleLabel = UILabel().then { label in

            label.text = title
            label.textAlignment = .left
            label.textColor = .primaryText
            label.font = .main(weight: .medium, size: 14)
            label.numberOfLines = 0
        }

        subTitleLabel = UILabel().then { label in

            label.text = subTitle
            label.textAlignment = .left
            label.textColor = .primaryText
            label.font = .main(weight: .regular, size: 12)
            label.numberOfLines = 0
        }

        _ = UIStackView().then { stackView in

            stackView.axis = .vertical
            stackView.distribution = .fill
            stackView.spacing = 0
            stackView.alignment = .leading

            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(subTitleLabel)

            addSubview(stackView) {
                $0.left.top.bottom.equalToSuperview().inset(4)
                $0.right.equalToSuperview().inset(19)
            }
        }
    }
}
