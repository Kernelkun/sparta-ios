//
//  LCDatesSelectorHeaderTableView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 14.02.2022.
//

import UIKit

class LCDatesSelectorHeaderTableView: UITableViewHeaderFooterView {

    // MARK: - UI

    private var titleLabel: UILabel!

    // MARK: - Initializers

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("LCDatesSelectorHeaderTableView")
    }

    // MARK: - Public methods

    func apply(title: String) {
        titleLabel.text = title.uppercased()
    }

    // MARK: - Private methods

    private func setupUI() {

        titleLabel = UILabel().then { titleLabel in

            titleLabel.font = .main(weight: .medium, size: 12)
            titleLabel.textColor = .neutral10
            titleLabel.numberOfLines = 1
            titleLabel.textAlignment = .left
            titleLabel.text = "Months"

            addSubview(titleLabel) {
                $0.left.equalToSuperview().offset(16)
                $0.bottom.equalToSuperview().inset(6)
            }
        }

        _ = UIView().then { view in

            view.backgroundColor = .neutral10

            addSubview(view) {
                $0.left.right.equalToSuperview().inset(16)
                $0.bottom.equalToSuperview()
                $0.height.equalTo(CGFloat.separatorWidth)
            }
        }
    }
}
