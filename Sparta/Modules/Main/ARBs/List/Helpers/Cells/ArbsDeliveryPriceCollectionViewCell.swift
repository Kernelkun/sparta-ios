//
//  ArbsDeliveryPriceCollectionViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 04.01.2021.
//

import UIKit
import SpartaHelpers
import NetworkingModels

class ArbsDeliveryPriceCollectionViewCell: UICollectionViewCell, ArbTappableCell {

    // MARK: - UI

    private var firstLabel: KeyedLabel<String>!
    private var secondLabel: KeyedLabel<String>!
    private var thirdLabel: KeyedLabel<String>!
    private var fourthLabel: KeyedLabel<String>!
    private var fifthLabel: KeyedLabel<String>!
    private var sixLabel: KeyedLabel<String>!
    private var bottomLine: UIView!

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

    override func prepareForReuse() {
        super.prepareForReuse()

        stopObservingAllArbsEvents()
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        if let layoutAttributes = layoutAttributes as? GridViewLayoutAttributes {
            backgroundColor = layoutAttributes.backgroundColor
        }
    }

    // MARK: - Public methods

    func apply(arb: Arb) {
        self.arb = ArbsSyncManager.intance.fetchUpdatedState(for: arb)

        setupUI(for: arb)
        observeArbs(arb)
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

        _ = UIStackView().then { stackView in

            stackView.addArrangedSubview(firstLabel)
            stackView.addArrangedSubview(secondLabel)
            stackView.addArrangedSubview(thirdLabel)
            stackView.addArrangedSubview(fourthLabel)
            stackView.addArrangedSubview(fifthLabel)
            stackView.addArrangedSubview(sixLabel)

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

    private func setupUI(for arb: Arb) {
        let months = arb.months

        for (index, label) in labels.enumerated() {

            if months.count >= index {
                let month = arb.months[index]

                label.text = month.deliveredPrice?.value.value ?? "-"
                label.textColor = month.deliveredPrice?.value.valueColor ?? .numberGray
                label.setKey(month.uniqueIdentifier)
            } else {
                label.text = "-"
                label.textColor = .numberGray
            }
        }
    }

    private func updateUI(for arb: Arb) {
        arb.months.forEach { month in
            guard let label = labels.first(where: { $0.key == month.uniqueIdentifier }) else { return }

            label.text = month.deliveredPrice?.value.value ?? "-"
            label.textColor = month.deliveredPrice?.value.valueColor ?? .numberGray
        }
    }

    // MARK: - Events

    @objc
    private func tapEvent() {
        _tapClosure?(arb)
    }
}

extension ArbsDeliveryPriceCollectionViewCell: ArbsObserver {

    func arbsDidReceiveResponse(for arb: Arb) {
        onMainThread {
            self.updateUI(for: arb)
        }
    }
}
