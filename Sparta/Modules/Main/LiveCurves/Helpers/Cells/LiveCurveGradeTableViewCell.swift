//
//  LiveCurveGradeTableViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 18.12.2020.
//

import UIKit

class LiveCurveGradeTableViewCell: UITableViewCell {

    // MARK: - UI

    private var titleLabel: UILabel!
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

    func apply(title: String, for indexPath: IndexPath) {
        titleLabel.text = title

        if indexPath.section % 2 == 0 { // even
            backgroundColor = UIGridViewConstants.oddLineBackgroundColor
        } else { // odd
            backgroundColor = UIGridViewConstants.evenLineBackgroundColor
        }
    }

    // MARK: - Private methods

    private func setupUI() {

        selectedBackgroundView = UIView().then { $0.backgroundColor = .clear }
        tintColor = .controlTintActive

        titleLabel = UILabel().then { label in

            label.textAlignment = .left
            label.textColor = .white
            label.numberOfLines = 2
            label.font = .main(weight: .regular, size: 14)
        }

        _ = UIStackView().then { stackView in

            stackView.addArrangedSubview(titleLabel)

            stackView.axis = .vertical
            stackView.alignment = .leading
            stackView.spacing = 8
            stackView.distribution = .fillProportionally

            contentView.addSubview(stackView) {
                $0.right.equalToSuperview().inset(8)
                $0.centerY.equalToSuperview()
                $0.left.equalToSuperview().offset(16)
            }
        }

        bottomLine = UIView().then { view in

            view.backgroundColor = UIBlenderConstants.tableSeparatorLineColor

            contentView.addSubview(view) {
                $0.height.equalTo(CGFloat.separatorWidth)
                $0.left.right.bottom.equalToSuperview()
            }
        }
    }
}
