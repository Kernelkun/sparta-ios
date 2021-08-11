//
//  ArbPlaygroundResultInputPointView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 06.08.2021.
//

import UIKit
import SpartaHelpers

class ArbPlaygroundResultInputPointView: UIView {

    // MARK: - Public properties

    var inputField: RoundedTextField!

    // MARK: - Private properties

    private var titleLabel: UILabel!
    private var unitsLabel: UILabel!

    private let constructor: ArbPlaygroundResultInputPointViewConstructor

    // MARK: - Initializers

    init(constructor: ArbPlaygroundResultInputPointViewConstructor) {
        self.constructor = constructor
        super.init(frame: .zero)

        setupUI()
        updateUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Private methods

    private func setupUI() {
        titleLabel = UILabel().then { label in

            label.font = .main(weight: .regular, size: 18)
            label.textAlignment = .left
            label.textColor = .plMainText

            addSubview(label) {
                $0.centerY.equalToSuperview()
                $0.left.equalToSuperview().offset(12)
            }
        }

        unitsLabel = UILabel().then { label in

            label.font = .main(weight: .regular, size: 18)
            label.textAlignment = .right
            label.textColor = .plMainText

            addSubview(label) {
                $0.centerY.equalToSuperview()
                $0.right.equalToSuperview().inset(12)
            }
        }

        inputField = RoundedTextField().then { textField in

            textField.backgroundColor = .plElementBackground
            textField.icon = nil
            textField.textField.enterType = .numberLimit(range: -999.99...999.99)
            textField.textField.textAlignment = .right

            addSubview(textField) {
                $0.centerY.equalToSuperview()
                $0.right.equalTo(unitsLabel.snp.left).offset(-6)
                $0.size.equalTo(CGSize(width: 82, height: 33))
            }
        }

        _ = UIView().then { view in

            view.backgroundColor = ArbsPlaygroundUIConstants.separatorLineColor

            addSubview(view) {
                $0.height.equalTo(ArbsPlaygroundUIConstants.separatorLineWidth)
                $0.bottom.equalToSuperview()
                $0.right.left.equalToSuperview()
            }
        }
    }

    private func updateUI() {
        titleLabel.text = constructor.title
        unitsLabel.text = constructor.units
        inputField.textField.initialText = constructor.initialInputText
    }
}
