//
//  ArbsDeliveryMonthCollectionViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 04.01.2021.
//

import UIKit
import SpartaHelpers
import NetworkingModels

class ArbsDeliveryMonthCollectionViewCell: UICollectionViewCell, ArbTappableCell {

    // MARK: - UI

    private var firstLabel: KeyedLabel<String>!
    private var secondLabel: KeyedLabel<String>!
    private var thirdLabel: KeyedLabel<String>!
    private var fourthLabel: KeyedLabel<String>!
    private var fifthLabel: KeyedLabel<String>!
    private var sixLabel: KeyedLabel<String>!
    private var bottomLine: UIView!
    private var labelsStackView: UIStackView!

    private var labels: [KeyedLabel<String>] {
        [firstLabel, secondLabel, thirdLabel, fourthLabel, fifthLabel, sixLabel]
    }

    // MARK: - Private properties

    private var lastPriceCode: String!
    private var _tapClosure: TypeClosure<Arb>?

    // MARK: - Public accessors
    
    var arb: Arb!

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
        setupActions()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        if let layoutAttributes = layoutAttributes as? GridViewLayoutAttributes {
            backgroundColor = layoutAttributes.backgroundColor
        }
    }

    // MARK: - Public methods

    func apply(arb: Arb) {
        self.arb = arb

        labelsStackView.removeAllSubviews()

        for (index, label) in labels.enumerated() {
            guard index < arb.months.count else {
                label.text = "-"
                labelsStackView.addArrangedSubview(label)
                return
            }

            label.text = arb.months[index].name
            labelsStackView.addArrangedSubview(label)
        }
    }

    func onTap(completion: @escaping TypeClosure<Arb>) {
        _tapClosure = completion
    }

    // MARK: - Private methods

    private func setupUI() {

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectedBackgroundView = UIView().then { $0.backgroundColor = .clear }
        tintColor = .controlTintActive

        firstLabel = KeyedLabel<String>().then { label in

            label.textAlignment = .center
            label.textColor = .tablePoint
            label.font = .main(weight: .regular, size: 13)
            label.isUserInteractionEnabled = true
        }

        secondLabel = KeyedLabel<String>().then { label in

            label.textAlignment = .center
            label.textColor = .tablePoint
            label.font = .main(weight: .regular, size: 13)
            label.isUserInteractionEnabled = true
        }

        thirdLabel = KeyedLabel<String>().then { label in

            label.textAlignment = .center
            label.textColor = .tablePoint
            label.font = .main(weight: .regular, size: 13)
            label.isUserInteractionEnabled = true
        }

        fourthLabel = KeyedLabel<String>().then { label in

            label.textAlignment = .center
            label.textColor = .tablePoint
            label.font = .main(weight: .regular, size: 13)
            label.isUserInteractionEnabled = true
        }

        fifthLabel = KeyedLabel<String>().then { label in

            label.textAlignment = .center
            label.textColor = .tablePoint
            label.font = .main(weight: .regular, size: 13)
            label.isUserInteractionEnabled = true
        }

        sixLabel = KeyedLabel<String>().then { label in

            label.textAlignment = .center
            label.textColor = .tablePoint
            label.font = .main(weight: .regular, size: 13)
            label.isUserInteractionEnabled = true
        }

        labelsStackView = UIStackView().then { stackView in

            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 4
            stackView.distribution = .equalSpacing

            contentView.addSubview(stackView) {
                $0.center.equalToSuperview()
            }
        }

        bottomLine = UIView().then { view in

            view.backgroundColor = UIGridViewConstants.tableSeparatorLineColor

            contentView.addSubview(view) {
                $0.height.equalTo(CGFloat.separatorWidth)
                $0.left.right.bottom.equalToSuperview()
            }
        }
    }

    private func setupActions() {
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapEvent)))
    }

    // MARK: - Events

    @objc
    private func tapEvent() {
        _tapClosure?(arb)
    }
}
