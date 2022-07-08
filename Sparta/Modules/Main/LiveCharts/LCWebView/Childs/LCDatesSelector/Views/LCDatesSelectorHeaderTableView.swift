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
        fatalError(#function)
    }

    // MARK: - Public methods

    func apply(title: String) {
        titleLabel.text = title.lowercased().capitalized + "s"
    }

    // MARK: - Private methods

    private func setupUI() {

        contentView.backgroundColor = .neutral85

        titleLabel = UILabel().then { titleLabel in

            titleLabel.font = .main(weight: .medium, size: 12)
            titleLabel.textColor = .neutral10
            titleLabel.numberOfLines = 1
            titleLabel.textAlignment = .left

            contentView.addSubview(titleLabel) {
                $0.left.equalToSuperview().offset(16)
                $0.bottom.equalToSuperview().inset(4)
            }
        }

        _ = UIView().then { view in

            view.backgroundColor = .neutral70

            contentView.addSubview(view) {
                $0.left.right.equalToSuperview().inset(16)
                $0.bottom.equalToSuperview()
                $0.height.equalTo(CGFloat.separatorWidth)
            }
        }
    }
}
