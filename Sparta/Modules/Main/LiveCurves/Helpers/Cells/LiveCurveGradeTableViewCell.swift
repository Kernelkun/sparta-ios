//
//  LiveCurveGradeTableViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 18.12.2020.
//

import UIKit

class LiveCurveGradeTableViewCell: UICollectionViewCell {

    // MARK: - UI

    private var unitsLabel: UILabel!
    private var titleLabel: UILabel!
    private var bottomLine: UIView!

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("LiveCurveGradeTableViewCell")
    }

    // MARK: - Lifecycle

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        if let layoutAttributes = layoutAttributes as? GridViewLayoutAttributes {
            backgroundColor = layoutAttributes.backgroundColor
        }
    }

    // MARK: - Public methods

    func apply(title: String, unit: String, for indexPath: IndexPath) {
        titleLabel.text = title
        unitsLabel.text = unit
    }

    // MARK: - Private methods

    private func setupUI() {

        selectedBackgroundView = UIView().then { $0.backgroundColor = .clear }
        tintColor = .controlTintActive

        unitsLabel = UILabel().then { label in

            label.textAlignment = .left
            label.textColor = .white
            label.numberOfLines = 1
            label.font = .main(weight: .regular, size: 14)

            contentView.addSubview(label) {
                $0.right.equalToSuperview().inset(8)
                $0.centerY.equalToSuperview()
                $0.width.equalTo(40)
            }
        }

        titleLabel = UILabel().then { label in

            label.textAlignment = .left
            label.textColor = .white
            label.numberOfLines = 2
            label.font = .main(weight: .regular, size: 14)

            contentView.addSubview(label) {
                $0.left.equalToSuperview().offset(8)
                $0.centerY.equalToSuperview()
                $0.right.equalTo(unitsLabel.snp.left).offset(-4)
            }
        }

        bottomLine = UIView().then { view in

            view.backgroundColor = UIGridViewConstants.tableSeparatorLineColor

            contentView.addSubview(view) {
                $0.height.equalTo(CGFloat.separatorWidth)
                $0.left.right.bottom.equalToSuperview()
            }
        }
    }
}
