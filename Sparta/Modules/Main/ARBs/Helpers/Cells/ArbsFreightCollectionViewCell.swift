//
//  ArbsFreightCollectionViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 04.01.2021.
//

import UIKit
import SpartaHelpers
import NetworkingModels

class ArbsFreightCollectionViewCell: UICollectionViewCell {

    // MARK: - UI

    private var firstLabel: UILabel!
    private var secondLabel: UILabel!
    private var thirdLabel: UILabel!
    private var bottomLine: UIView!

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

//        stopObservingAllLiveCurvesEvents()
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

        firstLabel = UILabel().then { label in

            label.textAlignment = .left
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.isUserInteractionEnabled = true
        }

        secondLabel = UILabel().then { label in

            label.textAlignment = .left
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.isUserInteractionEnabled = true
        }

        thirdLabel = UILabel().then { label in

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
            stackView.alignment = .trailing
            stackView.spacing = 4
            stackView.distribution = .fillProportionally

            contentView.addSubview(stackView) {
                $0.centerY.equalToSuperview()
                $0.left.right.equalToSuperview()
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

            firstLabel.text = month.freight.routeType.displayRouteValue
        }

        if months.count >= 2 {
            let month = arb.months[1]

            secondLabel.text = month.freight.routeType.displayRouteValue
        }

        if months.count >= 3 {
            let month = arb.months[2]

            thirdLabel.text = month.freight.routeType.displayRouteValue
        }
    }

    // MARK: - Events

    @objc
    private func tapEvent() {
        _tapClosure?(indexPath)
    }
}
