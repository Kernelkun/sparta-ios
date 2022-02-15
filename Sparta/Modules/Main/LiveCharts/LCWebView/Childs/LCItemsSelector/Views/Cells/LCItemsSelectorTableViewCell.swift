//
//  LCItemsSelectorTableViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 13.02.2022.
//

import UIKit
import SpartaHelpers

class LCItemsSelectorTableViewCell: UITableViewCell {

    // MARK: - UI

    private var titleLabel: UILabel!

    // MARK: - Private properties

    private var item: LCWebViewModel.Item?
    private var _tapClosure: TypeClosure<LCWebViewModel.Item>?

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("LCItemsSelectorTableViewCell")
    }

    // MARK: - Public methods

    func apply(item: LCWebViewModel.Item, onTap: @escaping TypeClosure<LCWebViewModel.Item>) {
        self.item = item

        titleLabel.text = item.title
        _tapClosure = onTap
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

        // gestures

        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapEvent)))
    }

    // MARK: - Events

    @objc
    private func onTapEvent() {
        guard let item = item else { return }

        _tapClosure?(item)
    }
}
