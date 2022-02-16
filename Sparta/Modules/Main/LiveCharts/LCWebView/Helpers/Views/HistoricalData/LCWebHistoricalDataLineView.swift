//
//  LCWebHistoricalDataLineView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 09.02.2022.
//

import UIKit

class LCWebHistoricalDataLineView: UIView {

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Public methods

    func setupUI(firstHighlight: LCWebViewModel.Highlight?, secondHighlight: LCWebViewModel.Highlight?) {
        let firstTitleString = firstHighlight?.type.rawValue ?? ""
        let secondTitleString = secondHighlight?.type.rawValue ?? ""

        let titleAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.neutral35,
                                                              .font: UIFont.main(weight: .medium, size: 12)]

        let valueAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.neutral10,
                                                              .font: UIFont.main(weight: .regular, size: 16)]

        func attributedString(for string: String, attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {
            NSMutableAttributedString(string: string, attributes: attributes)
        }

        let firstItemView = LCWebHistoricalDataItemView(configurator: .init(titleText: attributedString(for: firstTitleString, attributes: titleAttributes),
                                                                            valueText: attributedString(for: firstHighlight?.value ?? "", attributes: valueAttributes)))

        let secondItemView = LCWebHistoricalDataItemView(configurator: .init(titleText: attributedString(for: secondTitleString, attributes: titleAttributes),
                                                                             valueText: attributedString(for: secondHighlight?.value ?? "", attributes: valueAttributes)))

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
