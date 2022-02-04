//
//  ArbsPriceDifferentialsCollectionViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 01.02.2022.
//

import UIKit
import SpartaHelpers
import NetworkingModels

class ArbsPriceDifferentialsCollectionViewCell: UICollectionViewCell, ArbTappableCell {

    // MARK: - UI

    private var labelsStackView: UIStackView!
    private var bottomLine: UIView!

    // MARK: - Private properties

    private var lastAddedLabels: [KeyedLabel<String>] = []
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
        self.arb = App.instance.arbsSyncManager.fetchUpdatedState(for: arb)

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

        labelsStackView = UIStackView().then { stackView in

            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = ArbsUIConstants.listStackViewElementSpace
            stackView.distribution = .equalSpacing

            contentView.addSubview(stackView) {
                $0.top.equalToSuperview().inset(ArbsUIConstants.listStackViewTopSpace)
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

    private func keyedLabel(title: String, titleColor: UIColor, key: String) -> KeyedLabel<String> {
        KeyedLabel<String>().then { label in
            label.textAlignment = .center
            label.textColor = titleColor
            label.font = .main(weight: .regular, size: 13)
            label.isUserInteractionEnabled = true
            label.text = title
            label.setKey(key)
        }
    }

    private func setupUI(for arb: Arb) {
        labelsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        lastAddedLabels = []

        let months = arb.months
        let monthsCount = arb.presentationMonthsCount

        for index in 0..<monthsCount {

            var title: String
            var titleColor: UIColor
            var labelKey: String

            if months.count > index {
                let month = months[index]

                let priceDifferentials = month.deliveredPriceDifferentials.first

                title = priceDifferentials?.value?.value ?? "-"
                titleColor = priceDifferentials?.value?.valueColor ?? .numberGray
                labelKey = month.uniqueIdentifier
            } else {
                title = "-"
                titleColor = .numberGray
                labelKey = String.randomPassword
            }

            let label = keyedLabel(title: title, titleColor: titleColor, key: labelKey)
            let view = UIView().then { view in

                view.backgroundColor = .clear

                view.addSubview(label) {
                    $0.edges.equalToSuperview()
                    $0.height.equalTo(ArbsUIConstants.listStackViewElementHeight)
                }
            }

            labelsStackView.addArrangedSubview(view)
            lastAddedLabels.append(label)
        }
    }

    private func updateUI(for arb: Arb) {
        arb.months.forEach { month in
            guard let label = lastAddedLabels.first(where: { $0.key == month.uniqueIdentifier }) else { return }

            let priceDifferentials = month.deliveredPriceDifferentials.first

            label.text = priceDifferentials?.value?.value ?? "-"
            label.textColor = priceDifferentials?.value?.valueColor ?? .numberGray
        }
    }

    // MARK: - Events

    @objc
    private func tapEvent() {
        _tapClosure?(arb)
    }
}

extension ArbsPriceDifferentialsCollectionViewCell: ArbsObserver {

    func arbsDidReceiveResponse(for arb: Arb) {
        onMainThread {
            self.updateUI(for: arb)
        }
    }
}
