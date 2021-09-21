//
//  StepperView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 05.08.2021.
//

import UIKit
import SpartaHelpers

struct StepperViewConstructor<T> where T: Numeric, T: Comparable, T: CVarArg {
    let range: ClosedRange<T>
    let step: T
    var startValue: T
}

protocol StepperViewDelegate: AnyObject {
    func stepperViewDidChangeValue<T>(_ view: StepperView<T>, newValue: T, sign: FloatingPointSign) where T: Numeric, T: Comparable, T: CVarArg
}

class StepperView<T>: UIView where T: Numeric, T: Comparable, T: CVarArg {

    enum State {
        case inactive
        case active(constructor: StepperViewConstructor<T>)
    }

    // MARK: - Public properties

    weak var delegate: StepperViewDelegate?

    var state: State {
        didSet {
            updateUI()
        }
    }

    // MARK: - UI

    private var numberLabel: UILabel!
    private var minusButton: TappableButton!
    private var plusButton: TappableButton!

    // MARK: - Private properties

    private var currentValue: T = 0
    private var _valueChangeClosure: TypeClosure<T>?

    // MARK: - Initializers

    init() {
        state = .inactive
        super.init(frame: .zero)

        setupUI()
        updateUIForValue()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Public methods

    func onChangeValue(completion: @escaping TypeClosure<T>) {
        _valueChangeClosure = completion
    }

    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = UIColor.plElementBackground
        layer.cornerRadius = 8

        minusButton = TappableButton().then { button in

            button.setImage(UIImage(named: "ic_element_minus"), for: .normal)

            button.onTap { [unowned self] _ in
                self.decreaseValue()
            }

            addSubview(button) {
                $0.top.left.bottom.equalToSuperview()
                $0.width.equalTo(41)
            }
        }

        _ = UIView().then { view in

            view.backgroundColor = UIColor.secondaryText.withAlphaComponent(0.18)
            view.layer.cornerRadius = 0.5

            addSubview(view) {
                $0.left.equalTo(minusButton.snp.right)
                $0.centerY.equalToSuperview()
                $0.width.equalTo(1)
                $0.height.equalTo(15)
            }
        }

        plusButton = TappableButton().then { button in

            button.setImage(UIImage(named: "ic_element_plus"), for: .normal)

            button.onTap { [unowned self] _ in
                self.increaseValue()
            }

            addSubview(button) {
                $0.top.right.bottom.equalToSuperview()
                $0.width.equalTo(41)
            }
        }

        let rightLineView = UIView().then { view in

            view.backgroundColor = UIColor.plSeparator
            view.layer.cornerRadius = 0.5

            addSubview(view) {
                $0.right.equalTo(plusButton.snp.left)
                $0.centerY.equalToSuperview()
                $0.width.equalTo(CGFloat.separatorWidth)
                $0.height.equalTo(15)
            }
        }

        numberLabel = UILabel().then { label in

            label.font = .main(weight: .regular, size: 17)
            label.numberOfLines = 1
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.2
            label.baselineAdjustment = .alignCenters
            label.textAlignment = .center
            label.textColor = UIColor.primaryText.withAlphaComponent(0.6)

            addSubview(label) {
                $0.left.equalTo(minusButton.snp.right).offset(3)
                $0.right.equalTo(plusButton.snp.left).inset(-3)
                $0.centerY.equalToSuperview()
                $0.height.equalTo(rightLineView)
            }
        }
    }

    private func updateUI() {
        switch state {
        case .inactive:
            numberLabel.text = "-"
            numberLabel.textColor = UIColor.primaryText.withAlphaComponent(0.2)
            backgroundColor = .plInactiveElementBackground
            minusButton.tintColor = .white.withAlphaComponent(0.2)
            plusButton.tintColor = .white.withAlphaComponent(0.2)

        case .active(let constructor):
            numberLabel.textColor = UIColor.primaryText.withAlphaComponent(0.6)
            backgroundColor = .plElementBackground
            minusButton.tintColor = .white
            plusButton.tintColor = .white

            currentValue = constructor.startValue
            updateUIForValue()
        }
    }

    private func updateUIForValue() {
        if let currentValue = currentValue as? Double {
            numberLabel.text = currentValue.toFormattedString
        } else if let currentValue = currentValue as? Int {
            numberLabel.text = currentValue.toFormattedString
        }
    }

    private func decreaseValue() {
        guard case let .active(constructor) = state else { return }

        let newValue = currentValue - constructor.step

        if newValue >= constructor.range.lowerBound {
            currentValue = newValue
        } else {
            currentValue = constructor.range.lowerBound
        }

        updateUIForValue()
        delegate?.stepperViewDidChangeValue(self, newValue: currentValue, sign: .minus)
    }

    private func increaseValue() {
        guard case let .active(constructor) = state else { return }

        let newValue = currentValue + constructor.step

        if newValue <= constructor.range.upperBound {
            currentValue = newValue
        } else {
            currentValue = constructor.range.upperBound
        }

        updateUIForValue()
        delegate?.stepperViewDidChangeValue(self, newValue: currentValue, sign: .plus)
    }
}
