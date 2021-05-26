//
//  LCPortfolioAddItemTableViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 14.05.2021.
//

import UIKit

class LCPortfolioAddItemTableViewCell: UITableViewCell {

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

    func apply(item: LCPortfolioAddItemViewModel.Item) {
        titleLabel.text = item.title
        titleLabel.textColor = item.isActive ? .primaryText : UIColor.primaryText.withAlphaComponent(0.47)
    }

    // MARK: - Private methods

    private func setupUI() {

        backgroundColor = .clear
        selectedBackgroundView = UIView().then { $0.backgroundColor = .mainBackground }
        tintColor = .controlTintActive

        titleLabel = UILabel().then { label in

            label.textAlignment = .left
            label.textColor = .primaryText
            label.font = .main(weight: .regular, size: 17)
            label.numberOfLines = 1

            contentView.addSubview(label) {
                $0.centerY.equalToSuperview()
                $0.left.right.equalToSuperview().offset(16)
            }
        }
    }
}
