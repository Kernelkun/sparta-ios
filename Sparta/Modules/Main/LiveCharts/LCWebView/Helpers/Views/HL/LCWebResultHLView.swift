//
//  LCWebResultHLView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 09.02.2022.
//

import UIKit

class LCWebResultHLView: UIView {

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
        layer.cornerRadius = 10
        backgroundColor = UIColor.neutral85

        let highItemTitleString = "Today's High"
        let lowItemTitleString = "Today's Low"

        let titleAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.neutral35,
                                                              .font: UIFont.main(weight: .regular, size: 12)]

        let greenValueAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.numberGreen,
                                                                   .font: UIFont.main(weight: .regular, size: 18)]

        let redValueAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.numberRed,
                                                                 .font: UIFont.main(weight: .regular, size: 18)]

        func attributedString(for string: String, attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {
            NSMutableAttributedString(string: string, attributes: attributes)
        }

        let highItemView = LCWebResultItemView(configurator: .init(titleText: attributedString(for: highItemTitleString, attributes: titleAttributes),
                                                                   valueText: attributedString(for: "12.56", attributes: greenValueAttributes)))

        let lowItemView = LCWebResultItemView(configurator: .init(titleText: attributedString(for: lowItemTitleString, attributes: titleAttributes),
                                                                  valueText: attributedString(for: "-9.82", attributes: redValueAttributes)))

        let lineView = UIView().then { view in

            view.backgroundColor = .secondaryText

            addSubview(view) {
                $0.top.equalToSuperview().offset(11)
                $0.bottom.equalToSuperview().inset(10)
                $0.width.equalTo(CGFloat.separatorWidth)
                $0.centerX.equalToSuperview()
            }
        }

        highItemView.do { view in

            addSubview(view) {
                $0.left.centerY.equalToSuperview()
                $0.right.equalTo(lineView.snp.left)
            }
        }

        lowItemView.do { view in

            addSubview(view) {
                $0.centerY.right.equalToSuperview()
                $0.left.equalTo(lineView.snp.right)
            }
        }
    }
}
