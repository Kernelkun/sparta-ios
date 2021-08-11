//
//  ArbPlaygroundResultMainPointView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 06.08.2021.
//

import UIKit

class ArbPlaygroundResultMainPointView: UIView {

    // MARK: - Public properties

    var separatorLine: UIView!

    // MARK: - Private properties

    private var titleLabel: UILabel!
    private var valueLabel: UILabel!
    private var unitsLabel: UILabel!

    private let constructor: ArbPlaygroundResultMainPointViewConstructor

    // MARK: - Initializers

    init(constructor: ArbPlaygroundResultMainPointViewConstructor) {
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

        valueLabel = UILabel().then { label in

            label.font = .main(weight: .regular, size: 18)
            label.textAlignment = .right
            label.textColor = .plMainText

            addSubview(label) {
                $0.centerY.equalToSuperview()
                $0.right.equalTo(unitsLabel.snp.left).offset(-6)
            }
        }

        separatorLine = UIView().then { view in

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
        valueLabel.text = constructor.value
        valueLabel.textColor = constructor.valueColor
    }
}
