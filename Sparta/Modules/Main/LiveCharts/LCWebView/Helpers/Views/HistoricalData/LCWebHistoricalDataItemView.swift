//
//  LCWebHistoricalDataItemView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 09.02.2022.
//

import UIKit

class LCWebHistoricalDataItemView: UIView {

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Private methods

    private func setupUI() {
        let firstTitleString = "Last Price"
        let secondTitleString = "Change vs Yesterday Close"

        let titleAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.secondaryText,
                                                              .font: UIFont.main(weight: .medium, size: 12)]

        let valueAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.numberGray,
                                                              .font: UIFont.main(weight: .regular, size: 16)]

        func attributedString(for string: String, attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {
            NSMutableAttributedString(string: string, attributes: attributes)
        }

        let firstItemView = LCWebResultItemView(configurator: .init(titleText: attributedString(for: firstTitleString, attributes: titleAttributes),
                                                                    valueText: attributedString(for: "24.12", attributes: valueAttributes)))

        let secondItemView = LCWebResultItemView(configurator: .init(titleText: attributedString(for: secondTitleString, attributes: titleAttributes),
                                                                     valueText: attributedString(for: "-9.32", attributes: valueAttributes)))

        firstItemView.do { view in

            addSubview(view) {
                $0.left.top.bottom.equalToSuperview()
                $0.width.equalToSuperview().multipliedBy(0.5)
            }
        }

        secondItemView.do { view in

            addSubview(view) {
                $0.right.top.bottom.equalToSuperview()
                $0.width.equalToSuperview().multipliedBy(0.5)
            }
        }
    }
}
