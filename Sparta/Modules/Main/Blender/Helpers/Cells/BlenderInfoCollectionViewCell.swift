//
//  BlenderInfoCollectionViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 02.12.2020.
//

import UIKit

class BlenderInfoCollectionViewCell: UICollectionViewCell {

    // MARK: - UI

    private var titleLabel: UILabel!
    private var bottomLine: UIView!

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func apply(title: String, for indexPath: IndexPath) {
        titleLabel.text = title.capitalized

        if Int(title) ?? 0 >= 0 {
            titleLabel.textColor = .green
        } else {
            titleLabel.textColor = .red
        }

        if indexPath.section % 2 == 0 { // even
            backgroundColor = UIBlenderConstants.evenLineBackgroundColor
        } else { // odd
            backgroundColor = UIBlenderConstants.oddLineBackgroundColor
        }
    }

    // MARK: - Private methods

    private func setupUI() {

        selectedBackgroundView = UIView().then { $0.backgroundColor = .clear }
        tintColor = .controlTintActive

        titleLabel = UILabel().then { titleLabel in

            titleLabel.textAlignment = .center
            titleLabel.textColor = .white
            titleLabel.font = .main(weight: .regular, size: 14)

            contentView.addSubview(titleLabel) {
                $0.center.equalToSuperview()
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

