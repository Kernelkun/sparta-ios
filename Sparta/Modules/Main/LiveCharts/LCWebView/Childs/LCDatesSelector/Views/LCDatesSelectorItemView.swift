//
//  LCDatesSelectorItemView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 15.02.2022.
//

import UIKit
import NetworkingModels
import SpartaHelpers

class LCDatesSelectorItemView: TappableView {

    // MARK: - Public properties

    let dateSelector: LiveChartDateSelector

    // MARK: - UI

    private var titleLabel: UILabel!

    // MARK: - Private properties

    private let isSelected: Bool
    private var _onTapClosure: TypeClosure<LiveChartDateSelector>?

    // MARK: - Initializers

    init(dateSelector: LiveChartDateSelector, isSelected: Bool) {
        self.dateSelector = dateSelector
        self.isSelected = isSelected

        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Private methods

    private func setupUI() {
        titleLabel = UILabel().then { titleLabel in

            titleLabel.font = .main(weight: isSelected ? .medium : .regular, size: 14)
            titleLabel.textColor = isSelected ? .neutral10 : .neutral35
            titleLabel.numberOfLines = 1
            titleLabel.textAlignment = .center
            titleLabel.text = dateSelector.name
            titleLabel.adjustsFontSizeToFitWidth = true
//            titleLabel.minimumScaleFactor = 0.9

            addSubview(titleLabel) {
                $0.left.right.top.equalToSuperview()
            }
        }

        _ = UIView().then { view in

            view.backgroundColor = .controlTintActive
            view.isHidden = !isSelected

            addSubview(view) {
                $0.top.equalTo(titleLabel.snp.bottom).offset(3)
                $0.width.equalTo(25)
                $0.bottom.equalToSuperview()
                $0.height.equalTo(2)
                $0.centerX.equalTo(titleLabel)
            }
        }
    }
}
