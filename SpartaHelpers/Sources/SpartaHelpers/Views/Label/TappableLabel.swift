//
//  TappableLabel.swift
//  
//
//  Created by Yaroslav Babalich on 21.01.2021.
//

import UIKit

protocol TappableLabelDelegate: AnyObject {
    func tappableLabel(_ label: TappableLabel, didTapOn element: TappableLabel.Element)
}

class TappableLabel: UILabel {

    struct Element {
        let text: String

        func range(in string: String) -> NSRange {
            (string as NSString).range(of: text)
        }
    }

    // MARK: - Variables public

    weak var delegate: TappableLabelDelegate?

    var elements: [Element] = []

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    // MARK: - Private methods

    private func setup() {

        // general

        isUserInteractionEnabled = true

        // gestures

        addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapLabel(gesture:))))
    }

    // MARK: - Events

    @objc private func tapLabel(gesture: UITapGestureRecognizer) {

        let labelString = attributedText?.string ?? text ?? ""

        elements.forEach { element in
            if gesture.didTapAttributedTextInLabel(label: self, inRange: element.range(in: labelString)) {
                delegate?.tappableLabel(self, didTapOn: element)
            }
        }
    }
}

extension TappableLabel.Element: Equatable {

    static func == (lhs: TappableLabel.Element, rhs: TappableLabel.Element) -> Bool {
        lhs.text == rhs.text
    }
}
