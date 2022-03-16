//
//  LCWebHistoricalDataView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 09.02.2022.
//

import UIKit

class LCWebHistoricalDataView: UIView {

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Public methods

    func setupUI(highlights: [LCWebViewModel.Highlight]) {
        clear()

        backgroundColor = UIColor.neutral80

        _ = UIStackView().then { stackView in

            stackView.axis = .vertical
            stackView.distribution = .equalSpacing
            stackView.spacing = 16
            stackView.alignment = .fill

            let elements = highlights.chunked(into: 2)

            for element in elements {
                let view = LCWebHistoricalDataLineView()

                if element.first == element.last {
                    view.setupUI(firstHighlight: element.first, secondHighlight: nil)
                } else {
                    view.setupUI(firstHighlight: element.first, secondHighlight: element.last)
                }

                stackView.addArrangedSubview(view)
            }

            addSubview(stackView) {
                $0.top.bottom.equalToSuperview().inset(16)
                $0.left.right.equalToSuperview()
            }
        }
    }

    func clear() {
        removeAllSubviews()
    }
}
