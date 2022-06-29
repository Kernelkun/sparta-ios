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
    private var _tapClosure: TypeClosure<LiveCurveMonthInfoModel>?

    private var monthInfo: LiveCurveMonthInfoModel!
    private var indexPath: IndexPath!
    private var queue: OperationQueue!

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
        setupActions()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()

//        queue.cancelAllOperations()
        stopObservingAllLiveCurvesEvents()
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        if let layoutAttributes = layoutAttributes as? GridViewLayoutAttributes {
            backgroundColor = layoutAttributes.backgroundColor
        }
    }

    // MARK: - Public methods

    func apply(monthInfo: LiveCurveMonthInfoModel, for indexPath: IndexPath, animationQueue: OperationQueue) {
        self.monthInfo = monthInfo
        self.indexPath = indexPath
        self.queue = animationQueue

        titleLabel.text = monthInfo.priceValue
        lastPriceCode = monthInfo.priceCode
        observeLiveCurves(for: monthInfo.priceCode)
    }

    func onTap(completion: @escaping TypeClosure<LiveCurveMonthInfoModel>) {
        _tapClosure = completion
    }

    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
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
        _tapClosure?(monthInfo)
    }
}

extension LiveCurveInfoCollectionViewCell: LiveCurvesObserver {

    func liveCurvesDidReceiveResponse(for liveCurve: LiveCurve) {
//        onMainThread {
//            self.titleLabel.text = liveCurve.displayPrice
//
//            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveLinear, .allowUserInteraction]) {
//                self.contentView.layer.backgroundColor = liveCurve.state.color.withAlphaComponent(0.2).cgColor
//            } completion: { _ in
//                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveLinear, .allowUserInteraction]) {
//                    self.contentView.layer.backgroundColor = UIColor.clear.cgColor
//                } completion: { _ in
//                }
//            }
//        }

        let operation = CellAnimateOperation(duration: 1, delay: 0.0) { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.titleLabel.text = liveCurve.displayPrice

            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                strongSelf.contentView.layer.backgroundColor = liveCurve.state.color.withAlphaComponent(0.2).cgColor
            }

            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                strongSelf.contentView.layer.backgroundColor = UIColor.clear.cgColor
            }
        }
        queue.addOperation(operation)
    }
}
