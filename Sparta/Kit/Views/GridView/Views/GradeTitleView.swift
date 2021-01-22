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

    // MARK: - Private accessors

    private let insets: UIEdgeInsets

    // MARK: - Initializers

    init(insets: UIEdgeInsets) {
        self.insets = insets
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func apply(text: NSAttributedString? = nil) {
        titleLabel.attributedText = text
    }

    // MARK: - Private methods

    private func setupUI() {

        backgroundColor = UIGridViewConstants.evenLineBackgroundColor
        tintColor = .controlTintActive

        titleLabel = UILabel().then { titleLabel in

            titleLabel.textAlignment = .center
            titleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
            titleLabel.font = .main(weight: .regular, size: 12)
            titleLabel.numberOfLines = 0

            addSubview(titleLabel) {
                $0.top.equalToSuperview().offset(insets.top)
                $0.left.equalToSuperview().offset(insets.left)
                $0.right.equalToSuperview().inset(insets.right)
                $0.bottom.equalToSuperview().inset(insets.bottom)
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
