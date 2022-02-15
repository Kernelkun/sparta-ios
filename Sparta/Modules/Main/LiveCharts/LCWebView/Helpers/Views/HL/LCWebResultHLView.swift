//
//  LCWebResultHLView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 09.02.2022.
//

import UIKit
import SpartaHelpers

class LCWebResultHLView: TappableView {

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
        backgroundColor = UIColor.neutral80

        setupLeftContentView()
        setupRightContentView()
    }

    private func setupLeftContentView() {
        let mutableLabel = UILabel().then { label in

            let imageSizeConfig = UIImage.SymbolConfiguration(pointSize: 10)
            let triangleImage = UIImage(systemName: "arrowtriangle.up.fill", withConfiguration: imageSizeConfig)?
                .withTintColor(.numberGreen, renderingMode: .alwaysTemplate)

            let attachment = NSTextAttachment()
            attachment.image = triangleImage

            let mainTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.numberGreen,
                                                                     .font: UIFont.main(weight: .medium, size: 10)]

            let textString = NSAttributedString(string: " +0.35 +0.28%", attributes: mainTextAttributes)

            let imageString = NSMutableAttributedString(attachment: attachment)
            imageString.append(textString)

            label.attributedText = imageString
            label.layer.zPosition = 1

            addSubview(label) {
                $0.bottom.equalToSuperview().inset(2)
                $0.left.equalToSuperview().offset(16)
            }
        }

        _ = UILabel().then { label in

            label.numberOfLines = 0
            label.text = "126.85"
            label.font = .main(weight: .semibold, size: 28)
            label.textColor = .numberGreen
            label.layer.zPosition = 0

            addSubview(label) {
                $0.bottom.equalTo(mutableLabel.snp.top).inset(6)
                $0.left.equalToSuperview().offset(14)
            }
        }
    }

    private func setupRightContentView() {
        let highItemTitleString = "High"
        let lowItemTitleString = "Low"

        let textAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.neutral35,
                                                             .font: UIFont.main(weight: .medium, size: 9)]

        func attributedString(for string: String, attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {
            NSMutableAttributedString(string: string, attributes: attributes)
        }

        let highItemView = LCWebResultItemView(configurator: .init(titleText: attributedString(for: highItemTitleString, attributes: textAttributes),
                                                                   valueText: attributedString(for: "128.34", attributes: textAttributes)))

        let lowItemView = LCWebResultItemView(configurator: .init(titleText: attributedString(for: lowItemTitleString, attributes: textAttributes),
                                                                  valueText: attributedString(for: "112.12", attributes: textAttributes)))

        highItemView.do { view in

            addSubview(view) {
                $0.centerY.equalToSuperview().offset(-9)
                $0.right.equalToSuperview().inset(16)
            }
        }

        lowItemView.do { view in

            addSubview(view) {
                $0.centerY.equalToSuperview().offset(9)
                $0.right.equalToSuperview().inset(16)
            }
        }
    }
}
