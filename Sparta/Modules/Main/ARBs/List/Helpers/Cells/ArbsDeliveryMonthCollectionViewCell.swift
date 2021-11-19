//
//  ArbsDeliveryMonthCollectionViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 04.01.2021.
//

import UIKit
import SpartaHelpers
import NetworkingModels

class ArbsDeliveryMonthCollectionViewCell: UICollectionViewCell, ArbTappableCell {

    // MARK: - UI

    private var bottomLine: UIView!
    private var labelsStackView: UIStackView!

    // MARK: - Private properties

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

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        if let layoutAttributes = layoutAttributes as? GridViewLayoutAttributes {
            backgroundColor = layoutAttributes.backgroundColor
        }
    }

    // MARK: - Public methods

    func apply(arb: Arb) {
        self.arb = arb

        labelsStackView.removeAllSubviews()
        for month in arb.months {
            let monthName = month.name
            let label = keyedLabel(title: monthName, key: String.randomPassword)
            label.snp.makeConstraints {
                $0.height.equalTo(ArbsUIConstants.listStackViewElementHeight)
            }
            labelsStackView.addArrangedSubview(label)
        }
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

    private func keyedLabel(title: String, key: String) -> KeyedLabel<String> {
        KeyedLabel<String>().then { label in

            label.textAlignment = .center
            label.textColor = .tablePoint
            label.font = .main(weight: .regular, size: 13)
            label.isUserInteractionEnabled = true
            label.text = title
            label.setKey(key)
        }
    }

    private func setupActions() {
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapEvent)))
    }

    // MARK: - Events

    @objc
    private func tapEvent() {
        _tapClosure?(arb)
    }
}
