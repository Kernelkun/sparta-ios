//
//  LCPortfolioAddTableViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 14.05.2021.
//

import UIKit

class LCPortfolioAddTableViewCell: UITableViewCell {

    // MARK: - UI

    private var titleLabel: UILabel!

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("LCPortfolioAddTableViewCell")
    }

    // MARK: - Public methods

    func apply(title: String) {
        titleLabel.text = title
    }

    // MARK: - Private methods

    private func setupUI() {

        backgroundColor = .clear
        selectedBackgroundView = UIView().then { $0.backgroundColor = .mainBackground }
        tintColor = .controlTintActive

        titleLabel = UILabel().then { label in

            label.textAlignment = .center
            label.textColor = .primaryText
            label.font = .main(weight: .regular, size: 10)
            label.numberOfLines = 2

            contentView.addSubview(label) {
                $0.centerY.equalToSuperview()
                $0.left.equalToSuperview().offset(4)
            }
        }
    }
}

