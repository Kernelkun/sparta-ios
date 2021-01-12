//
//  ArbsDeliveryMonthCollectionViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 04.01.2021.
//

import UIKit
import SpartaHelpers
import NetworkingModels

class ArbsDeliveryMonthCollectionViewCell: UICollectionViewCell {

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

        let months = arb.months

        if months.count >= 1 {
            firstLabel.text = arb.months[0].name
        }

        if months.count >= 2 {
            secondLabel.text = arb.months[1].name
        }

        if months.count >= 3 {
            thirdLabel.text = arb.months[2].name
        }

//        titleLabel.text = monthInfo.priceValue.symbols2Value
//        lastPriceCode = monthInfo.priceCode
//        observeLiveCurves(for: monthInfo.priceCode)
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
            label.font = .main(weight: .regular, size: 10)
            label.isUserInteractionEnabled = true
        }

        secondLabel = UILabel().then { label in

            label.textAlignment = .left
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 10)
            label.isUserInteractionEnabled = true
        }

        thirdLabel = UILabel().then { label in

            label.textAlignment = .center
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 10)
            label.isUserInteractionEnabled = true
        }

        _ = UIStackView().then { stackView in

            stackView.addArrangedSubview(firstLabel)
            stackView.addArrangedSubview(secondLabel)
            stackView.addArrangedSubview(thirdLabel)

            stackView.axis = .vertical
            stackView.alignment = .leading
            stackView.spacing = 8
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

    // MARK: - Events

    @objc
    private func tapEvent() {
        _tapClosure?(indexPath)
    }
}

/*extension ArbsDeliveryMonthCollectionViewCell: LiveCurvesObserver {

    func liveCurvesDidReceiveResponse(for liveCurve: LiveCurve) {
        onMainThread {
            self.titleLabel.text = liveCurve.priceValue.symbols2Value

            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveLinear, .allowUserInteraction]) {
                self.contentView.layer.backgroundColor = liveCurve.state.color.withAlphaComponent(0.2).cgColor
            } completion: { _ in
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveLinear, .allowUserInteraction]) {
                    self.contentView.layer.backgroundColor = UIColor.clear.cgColor
                } completion: { _ in
                }
            }
        }
    }
}*/
