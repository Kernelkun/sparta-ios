//
//  ArbsDeliveryPriceCollectionViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 04.01.2021.
//

import UIKit
import SpartaHelpers
import NetworkingModels

class ArbsDeliveryPriceCollectionViewCell: UICollectionViewCell {

    // MARK: - UI

    private var firstLabel: KeyedLabel<String>!
    private var secondLabel: KeyedLabel<String>!
    private var thirdLabel: KeyedLabel<String>!
    private var bottomLine: UIView!

    private var labels: [KeyedLabel<String>] {
        [firstLabel, secondLabel, thirdLabel]
    }

    // MARK: - Private properties

    private var lastPriceCode: String!
    private var _tapClosure: TypeClosure<IndexPath>?
    private var indexPath: IndexPath!

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

    func apply(arb: Arb, for indexPath: IndexPath) {
        self.indexPath = indexPath

        updateUI(for: arb)
        observeArbs(for: arb.gradeCode)
    }

    func onTap(completion: @escaping TypeClosure<IndexPath>) {
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
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.isUserInteractionEnabled = true
        }

        secondLabel = KeyedLabel<String>().then { label in

            label.textAlignment = .center
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.isUserInteractionEnabled = true
        }

        thirdLabel = KeyedLabel<String>().then { label in

            label.textAlignment = .center
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.isUserInteractionEnabled = true
        }

        _ = UIStackView().then { stackView in

            stackView.addArrangedSubview(firstLabel)
            stackView.addArrangedSubview(secondLabel)
            stackView.addArrangedSubview(thirdLabel)

            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 4
            stackView.distribution = .fillProportionally

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

    private func updateUI(for arb: Arb) {
        let months = arb.months

        if months.count >= 1 {
            let month = arb.months[0]

            firstLabel.text = month.deliveredPrice.value.value
            firstLabel.textColor = month.deliveredPrice.value.valueColor
            firstLabel.setKey(month.name)
        }

        if months.count >= 2 {
            let month = arb.months[1]

            secondLabel.text = month.deliveredPrice.value.value
            secondLabel.textColor = month.deliveredPrice.value.valueColor
            secondLabel.setKey(month.name)
        }

        if months.count >= 3 {
            let month = arb.months[2]

            thirdLabel.text = month.deliveredPrice.value.value
            thirdLabel.textColor = month.deliveredPrice.value.valueColor
            thirdLabel.setKey(month.name)
        }
    }

    // MARK: - Events

    @objc
    private func tapEvent() {
        _tapClosure?(indexPath)
    }
}

extension ArbsDeliveryPriceCollectionViewCell: ArbsObserver {

    func arbsDidReceiveResponse(for arb: Arb) {
        onMainThread {
            self.updateUI(for: arb)
        }
    }
}
