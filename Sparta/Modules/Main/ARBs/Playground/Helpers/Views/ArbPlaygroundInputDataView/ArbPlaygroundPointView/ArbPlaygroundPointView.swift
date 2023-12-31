//
//  ArbPlaygroundPointView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 06.08.2021.
//

import UIKit

protocol ArbPlaygroundPointViewDelegate: AnyObject {
    func arbPlaygroundViewDidChangeValue<V>(_ view: ArbPlaygroundPointView<V>, newValue: V, sign: FloatingPointSign) where V: Numeric, V: Comparable, V: CVarArg
}

class ArbPlaygroundPointView<V>: UIView, StepperViewDelegate where V: Numeric, V: Comparable, V: CVarArg {

    enum State {
        case inactive
        case active(constructor: ArbPlaygroundPointViewConstructor<V>)
    }

    // MARK: - Public properties

    weak var delegate: ArbPlaygroundPointViewDelegate?

    var state: State {
        didSet {
            updateUI()
        }
    }

    // MARK: - UI

    private var titleLabel: UILabel!
    private var subTitle: UILabel!
    private var stepperView: StepperView<V>!
    private var unitsLabel: UILabel!

    // MARK: - Initializers

    init() {
        self.state = .inactive
        super.init(frame: .zero)

        setupUI()
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
        }

        subTitle = UILabel().then { label in

            label.font = .main(weight: .regular, size: 12)
            label.textAlignment = .left
            label.textColor = .plMainText
        }

        _ = UIStackView().then { stackView in

            stackView.axis = .vertical
            stackView.distribution = .equalSpacing
            stackView.spacing = 0
            stackView.alignment = .leading

            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(subTitle)

            addSubview(stackView) {
                $0.centerY.equalToSuperview()
                $0.left.equalToSuperview()
            }
        }

        unitsLabel = UILabel().then { label in

            label.font = .main(weight: .regular, size: 18)
            label.textAlignment = .left
            label.textColor = .plMainText

            addSubview(label) {
                $0.width.equalTo(50)
                $0.centerY.equalToSuperview()
                $0.right.equalToSuperview()
            }
        }

        _ = UIView().then { view in

            view.backgroundColor = ArbsPlaygroundUIConstants.separatorLineColor

            addSubview(view) {
                $0.height.equalTo(ArbsPlaygroundUIConstants.separatorLineWidth)
                $0.bottom.equalToSuperview()
                $0.right.equalTo(unitsLabel.snp.right).inset(3)
                $0.left.equalToSuperview().offset(12)
            }
        }

        stepperView = StepperView<V>().then { view in

            view.delegate = self

            addSubview(view) {
                $0.width.equalTo(156)
                $0.height.equalTo(32)
                $0.centerY.equalTo(unitsLabel)
                $0.right.equalTo(unitsLabel.snp.left).offset(-10)
            }
        }
    }

    private func updateUI() {
        switch state {
        case .inactive:
            titleLabel.text = "-"
            titleLabel.textColor = ArbsPlaygroundUIConstants.inactiveTintColor
            unitsLabel.text = ""
            stepperView.state = .inactive

        case .active(let constructor):
            titleLabel.text = constructor.title
            titleLabel.textColor = .plMainText
            unitsLabel.text = constructor.units

            if let subTitle = constructor.subTitle {
                self.subTitle.isHidden = false
                self.subTitle.text = subTitle
            } else {
                subTitle.isHidden = true
            }

            stepperView.state = .active(constructor: .init(range: constructor.range,
                                                           step: constructor.step,
                                                           startValue: constructor.startValue))
        }
    }

    // MARK: - StepperViewDelegate

    func stepperViewDidChangeValue<T>(_ view: StepperView<T>, newValue: T, sign: FloatingPointSign) where T: CVarArg, T: Comparable, T: Numeric {
        guard let newValue = newValue as? V else { return }

        delegate?.arbPlaygroundViewDidChangeValue(self, newValue: newValue, sign: sign)
    }
}
