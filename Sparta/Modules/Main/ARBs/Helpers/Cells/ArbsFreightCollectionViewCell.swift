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

    func apply(monthInfo: LiveCurveMonthInfoModel, for indexPath: IndexPath) {
        self.indexPath = indexPath

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

//            label.text = "+3.25"
            label.textAlignment = .left
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.isUserInteractionEnabled = true
        }

        secondLabel = UILabel().then { label in

//            label.text = "+3.25"
            label.textAlignment = .left
            label.textColor = .secondaryText
            label.font = .main(weight: .regular, size: 14)
            label.isUserInteractionEnabled = true
        }

        thirdLabel = UILabel().then { label in

//            label.text = "+3.25"
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

