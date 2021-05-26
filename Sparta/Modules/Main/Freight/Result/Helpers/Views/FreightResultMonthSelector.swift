//
//  FreightResultMonthSelector.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.01.2021.
//

import UIKit
import SpartaHelpers

protocol FreightResultMonthSelectorDelegate: class {
    func freightResultMonthSelectorDidTapLeftButton(view: FreightResultMonthSelector)
    func freightResultMonthSelectorDidTapRightButton(view: FreightResultMonthSelector)
}

class FreightResultMonthSelector: UIView {

    // MARK: - Public properties

    weak var delegate: FreightResultMonthSelectorDelegate?

    var isEnabledLeftButton: Bool = true {
        didSet {
            updateUI()
        }
    }

    var isEnabledRightButton: Bool = true {
        didSet {
            updateUI()
        }
    }

    var titleText: String = "" {
        didSet {
            updateUI()
        }
    }

    // MARK: - UI

    private var leftButton: TappableButton!
    private var rightButton: TappableButton!
    private var monthLabel: UILabel!

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setupUI() {

        leftButton = TappableButton(type: .system).then { button in

            button.clickableInset = -15
            button.tintColor = .primaryText
            button.setImage(UIImage(named: "ic_arrow_right_bold"), for: .normal)
            button.rotate(degrees: 180)

            button.onTap { [unowned self] _ in
                self.delegate?.freightResultMonthSelectorDidTapLeftButton(view: self)
            }

            addSubview(button) {
                $0.size.equalTo(CGSize(width: 18, height: 22))
                $0.left.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
        }

        rightButton = TappableButton(type: .system).then { button in

            button.clickableInset = -15
            button.tintColor = .primaryText
            button.setImage(UIImage(named: "ic_arrow_right_bold"), for: .normal)

            button.onTap { [unowned self] _ in
                self.delegate?.freightResultMonthSelectorDidTapRightButton(view: self)
            }

            addSubview(button) {
                $0.size.equalTo(CGSize(width: 18, height: 22))
                $0.right.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
        }

        monthLabel = UILabel().then { label in

            label.font = .main(weight: .regular, size: 17.5)
            label.textColor = .primaryText
            label.textAlignment = .center

            addSubview(label) {
                $0.left.equalTo(leftButton.snp.right)
                $0.right.equalTo(rightButton.snp.left)
                $0.top.bottom.equalToSuperview()
            }
        }
    }

    private func updateUI() {
        leftButton.isEnabled = isEnabledLeftButton
        rightButton.isEnabled = isEnabledRightButton
        monthLabel.text = titleText
    }
}
