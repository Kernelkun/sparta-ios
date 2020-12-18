//
//  GradeTitleView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 18.12.2020.
//

import UIKit

class GradeTitleView: UIView {

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

    func apply(title: String) {
        titleLabel.text = title.capitalized
    }

    // MARK: - Private methods

    private func setupUI() {

        backgroundColor = UIGridViewConstants.evenLineBackgroundColor
        tintColor = .controlTintActive

        titleLabel = UILabel().then { titleLabel in

            titleLabel.textAlignment = .center
            titleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
            titleLabel.font = .main(weight: .regular, size: 12)

            addSubview(titleLabel) {
                $0.center.equalToSuperview()
            }
        }

        bottomLine = UIView().then { view in

            view.backgroundColor = UIGridViewConstants.tableSeparatorLineColor

            addSubview(view) {
                $0.height.equalTo(CGFloat.separatorWidth)
                $0.left.right.bottom.equalToSuperview()
            }
        }
    }
}
