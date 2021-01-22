//
//  ArbsStatusCollectionViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 21.01.2021.
//

import UIKit
import SpartaHelpers
import NetworkingModels

class ArbsStatusCollectionViewCell: UICollectionViewCell {

    // MARK: - UI

    private var firstButton: KeyedButton<String>!
    private var secondButton: TappableButton!
    private var thirdButton: TappableButton!
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

//        if months.count >= 1 {
//            firstLabel.text = arb.months[0].name
//        }
//
//        if months.count >= 2 {
//            secondLabel.text = arb.months[1].name
//        }
//
//        if months.count >= 3 {
//            thirdLabel.text = arb.months[2].name
//        }

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

        firstButton = KeyedButton<String>().then { button in

            button.setTitle("Closed", for: .normal)
            button.setTitleColor(.red, for: .normal)
            button.titleLabel?.font = .main(weight: .regular, size: 11)

            button.snp.makeConstraints {
                $0.height.equalTo(15)
            }
        }

        secondButton = KeyedButton<String>().then { button in

            button.setTitle("Closed", for: .normal)
            button.setTitleColor(.red, for: .normal)
            button.titleLabel?.font = .main(weight: .regular, size: 11)

            button.snp.makeConstraints {
                $0.height.equalTo(15)
            }
        }

        thirdButton = KeyedButton<String>().then { button in

            button.setTitle("Closed", for: .normal)
            button.setTitleColor(.red, for: .normal)
            button.titleLabel?.font = .main(weight: .regular, size: 11)

            button.snp.makeConstraints {
                $0.height.equalTo(15)
            }
        }

        _ = UIStackView().then { stackView in

            stackView.addArrangedSubview(firstButton)
            stackView.addArrangedSubview(secondButton)
            stackView.addArrangedSubview(thirdButton)

            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 6
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
