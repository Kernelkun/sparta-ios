//
//  BlenderDescriptionTableViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 04.12.2020.
//

import UIKit

class BlenderDescriptionTableViewCell: UITableViewCell {

    // MARK: - UI

    private var titleLabel: UILabel!
    private var valueLabel: UILabel!
    private var bottomLine: UIView!

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("BlenderGradeTableViewCell")
    }

    // MARK: - Public methods

    func apply(key: String, value: String) {
        titleLabel.text = key
        valueLabel.text = value
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
                $0.top.bottom.equalToSuperview().inset(6)
                $0.left.equalToSuperview().offset(4)
                $0.centerY.equalToSuperview()
            }
        }

        valueLabel = UILabel().then { label in

            label.textAlignment = .right
            label.textColor = .primaryText
            label.font = .main(weight: .regular, size: 10)
            label.numberOfLines = 2

            contentView.addSubview(label) {
                $0.left.equalTo(titleLabel.snp.right).offset(16)
                $0.right.equalToSuperview().inset(4)
                $0.top.bottom.equalToSuperview().inset(4)
            }
        }

        bottomLine = UIView().then { view in

            view.backgroundColor = UIGridViewConstants.tableSeparatorLineColor

            contentView.addSubview(view) {
                $0.height.equalTo(CGFloat.separatorWidth)
                $0.left.right.equalToSuperview().inset(4)
                $0.bottom.equalToSuperview()
            }
        }
    }
}
