//
//  ArbsFreightCollectionViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 04.01.2021.
//

import UIKit
import SpartaHelpers
import NetworkingModels

class ArbsUserTgtCollectionViewCell: UICollectionViewCell, ArbTappableCell {

    // MARK: - UI

    private var bottomLine: UIView!
    private var labelsStackView: UIStackView!

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
            stackView.alignment = .fill
            stackView.spacing = ArbsUIConstants.listStackViewElementSpace
            stackView.distribution = .fill

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

    private func setupUI(for arb: Arb) {
        labelsStackView.removeAllArrangedSubviews()
        lastAddedLabels = []

        let months = arb.months
        let monthsCount = arb.presentationMonthsCount

        for index in 0..<monthsCount {

            var title: String
            var titleColor: UIColor
            var labelKey: String

            if months.count > index {
                let month = months[index]

                if let userTarget = month.dbProperties.fetchUserTarget()?.toDisplayFormattedString {
                    title = userTarget
                    titleColor = .tablePoint
                } else {
                    title = "-"
                    titleColor = .controlTintActive
                }

                labelKey = month.uniqueIdentifier
            } else {
                title = "-"
                titleColor = .controlTintActive
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

            if let userTarget = month.dbProperties.fetchUserTarget()?.toDisplayFormattedString {
                label.text = userTarget
                label.textColor = .tablePoint
            } else {
                label.text = "-"
                label.textColor = .controlTintActive
            }
        }
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

    // MARK: - Events

    @objc
    private func tapEvent() {
        _tapClosure?(arb)
    }
}

extension ArbsUserTgtCollectionViewCell: ArbsObserver {

    func arbsDidReceiveResponse(for arb: Arb) {
        onMainThread {
            self.updateUI(for: arb)
        }
    }
}
