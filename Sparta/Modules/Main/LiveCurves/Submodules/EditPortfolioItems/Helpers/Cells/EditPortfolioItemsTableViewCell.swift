//
//  EditPortfolioItemsTableViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 26.05.2021.
//

import UIKit

class EditPortfolioItemsTableViewCell: UITableViewCell {

    // MARK: - UI

    private var titleLabel: UILabel!

    override var isSelected: Bool {
        didSet { accessoryType = isSelected ? .detailDisclosureButton : .none }
    }

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("EditPortfolioItemsTableViewCell")
    }

    // MARK: - Public methods

    func apply(item: LCPortfolioAddItemViewModel.Item) {
        titleLabel.text = "Title"
//        titleLabel.textColor = item.isActive ? .primaryText : UIColor.primaryText.withAlphaComponent(0.47)
    }

    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = .clear
        selectedBackgroundView = UIView().then { $0.backgroundColor = .mainBackground }
        tintColor = .controlTintActive
        selectionStyle = .default

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
