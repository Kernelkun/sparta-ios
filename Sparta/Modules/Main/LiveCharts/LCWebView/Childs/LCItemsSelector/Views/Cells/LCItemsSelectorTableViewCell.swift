//
//  LCItemsSelectorTableViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 13.02.2022.
//

import UIKit

class LCItemsSelectorTableViewCell: UITableViewCell {

    // MARK: - UI

    private var titleLabel: UILabel!

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("LCItemsSelectorTableViewCell")
    }

    // MARK: - Public methods

    func apply(item: LCItemsSelectorViewModel.Item) {
        titleLabel.text = item.title
    }

    // MARK: - Private methods

    private func setupUI() {

        backgroundColor = .clear
        selectedBackgroundView = UIView().then { $0.backgroundColor = .mainBackground }
        tintColor = .controlTintActive
        selectionStyle = .none

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
