//
//  LCItemsSelectorHeaderTableView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 13.02.2022.
//

import UIKit

class LCItemsSelectorHeaderTableView: UITableViewHeaderFooterView {

    // MARK: - UI

    private var titleLabel: UILabel!

    // MARK: - Initializers

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("LCItemsSelectorHeaderTableView")
    }

    // MARK: - Public methods

    func apply(title: String) {
        titleLabel.text = title.uppercased()
    }

    // MARK: - Private methods

    private func setupUI() {

        contentView.backgroundColor = .mainBackground

        titleLabel = UILabel().then { titleLabel in

            titleLabel.font = .main(weight: .regular, size: 14)
            titleLabel.textColor = UIColor.primaryText.withAlphaComponent(0.47)
            titleLabel.numberOfLines = 1
            titleLabel.textAlignment = .left

            addSubview(titleLabel) {
                $0.centerY.equalToSuperview()
                $0.left.right.equalToSuperview().inset(16)
            }
        }

        _ = UIView().then { view in

            view.backgroundColor = .separator

            addSubview(view) {
                $0.left.bottom.right.equalToSuperview()
                $0.height.equalTo(CGFloat.separatorWidth)
            }
        }
    }
}
