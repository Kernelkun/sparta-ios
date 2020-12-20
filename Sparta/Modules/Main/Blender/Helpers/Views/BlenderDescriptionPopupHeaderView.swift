//
//  BlenderDescriptionPopupHeaderView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 05.12.2020.
//

import UIKit

class BlenderDescriptionPopupHeaderView: UITableViewHeaderFooterView {

    // MARK: - UI

    private var titleLabel: UILabel!
    private var valueLabel: UILabel!
    private var bottomLine: UIView!

    // MARK: - Initializers

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("BlenderGradeTableViewCell")
    }

    // MARK: - Private methods

    private func setupUI() {

        contentView.backgroundColor = .mainBackground
        backgroundColor = .mainBackground
        tintColor = .controlTintActive

        titleLabel = UILabel().then { label in

            label.textAlignment = .center
            label.textColor = UIColor.primaryText.withAlphaComponent(0.7)
            label.font = .main(weight: .lightItalic, size: 10)
            label.numberOfLines = 2
            label.text = "Component"

            addSubview(label) {
                $0.top.equalToSuperview().offset(16)
                $0.bottom.equalToSuperview().inset(5)
                $0.left.equalToSuperview().offset(4)
                $0.centerY.equalToSuperview()
            }
        }

        valueLabel = UILabel().then { label in

            label.textAlignment = .center
            label.textColor = UIColor.primaryText.withAlphaComponent(0.7)
            label.font = .main(weight: .lightItalic, size: 10)
            label.numberOfLines = 1
            label.text = "Blend vol%"

            addSubview(label) {
                $0.right.equalToSuperview().inset(4)
                $0.top.equalToSuperview().offset(16)
                $0.bottom.equalToSuperview().inset(5)
            }
        }

        bottomLine = UIView().then { view in

            view.backgroundColor = UIGridViewConstants.tableSeparatorLineColor

            addSubview(view) {
                $0.height.equalTo(CGFloat.separatorWidth)
                $0.left.right.equalToSuperview().inset(4)
                $0.bottom.equalToSuperview()
            }
        }
    }
}
