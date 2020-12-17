//
//  LiveCurveInfoCollectionViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 17.12.2020.
//

import UIKit
import SpartaHelpers
import NetworkingModels

class LiveCurveInfoCollectionViewCell: UICollectionViewCell {

    // MARK: - UI

    private var titleLabel: UILabel!
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

        stopObservingLiveCurves(for: lastPriceCode)
    }

    // MARK: - Public methods

    func apply(monthInfo: LiveCurveMonthInfoModel, for indexPath: IndexPath) {
        self.indexPath = indexPath

        if let priceValue = monthInfo.priceValue {
            titleLabel.text = priceValue
        }

        lastPriceCode = monthInfo.priceCode
        observeLiveCurves(for: monthInfo.priceCode)

        if indexPath.section % 2 == 0 { // even
            backgroundColor = UIBlenderConstants.evenLineBackgroundColor
        } else { // odd
            backgroundColor = UIBlenderConstants.oddLineBackgroundColor
        }
    }

    func onTap(completion: @escaping TypeClosure<IndexPath>) {
        _tapClosure = completion
    }

    // MARK: - Private methods

    private func setupUI() {

        selectedBackgroundView = UIView().then { $0.backgroundColor = .clear }
        tintColor = .controlTintActive

        titleLabel = UILabel().then { label in

            label.textAlignment = .center
            label.textColor = .white
            label.font = .main(weight: .regular, size: 14)
            label.isUserInteractionEnabled = true
        }

        _ = UIStackView().then { stackView in

            stackView.addArrangedSubview(titleLabel)

            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 8
            stackView.distribution = .fillProportionally

            contentView.addSubview(stackView) {
                $0.left.right.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
        }

        bottomLine = UIView().then { view in

            view.backgroundColor = UIBlenderConstants.tableSeparatorLineColor

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

extension LiveCurveInfoCollectionViewCell: LiveCurvesObserver {

    func liveCurvesDidReceiveResponse(for liveCurve: LiveCurve) {
        titleLabel.text = "\(liveCurve.priceValue)"
    }
}
