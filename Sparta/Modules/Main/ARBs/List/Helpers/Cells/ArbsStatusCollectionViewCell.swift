//
//  ArbsStatusCollectionViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 21.01.2021.
//

import UIKit
import SpartaHelpers
import NetworkingModels

class ArbsStatusCollectionViewCell: UICollectionViewCell, ArbTappableCell {

    // MARK: - UI

    private var viewsStackView: UIStackView!
    private var bottomLine: UIView!

    // MARK: - Public properties

    var arb: Arb!

    // MARK: - Private properties

    private var lastPriceCode: String!
    private var _tapClosure: TypeClosure<Arb>?

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

        observeArbs(arb)
        updateUI(for: arb)
    }

    func onTap(completion: @escaping TypeClosure<Arb>) {
        _tapClosure = completion
    }

    // MARK: - Private methods

    private func updateUI(for arb: Arb) {
        viewsStackView.removeAllSubviews()

        arb.months.forEach { month in
            if let position = month.position {
                viewsStackView.addArrangedSubview(progressView(position: position))
            } else {
                viewsStackView.addArrangedSubview(inputTGTView())
            }
        }

        // in some case we could have 5 months insteda of 6
        if viewsStackView.arrangedSubviews.count == 5 {
            let hotfixLabel = inputTGTView(title: "-")
            viewsStackView.addArrangedSubview(hotfixLabel)
        }
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectedBackgroundView = UIView().then { $0.backgroundColor = .clear }
        tintColor = .controlTintActive

        viewsStackView = UIStackView().then { stackView in

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

    // MARK: - Views

    private func progressView(position: ArbMonth.Position) -> UIView {
        UIView().then { view in

            _ = ProgressView().then { progressView in

                progressView.apply(progressPercentage: position.percentage, color: position.color)

                view.addSubview(progressView) {
                    $0.width.equalTo(36)
                    $0.height.equalTo(9)
                    $0.center.equalToSuperview()
                }
            }

            view.snp.makeConstraints {
                $0.height.equalTo(ArbsUIConstants.listStackViewElementHeight)
            }
        }
    }

    private func inputTGTView(title: String? = nil) -> UIView {
        UIView().then { view in

            _ = UILabel().then { label in

                let title = title?.nullable != nil ? title.required() : "ArbsPage.Status.InputTgt.Title".localized
                label.text = title
                label.textColor = .controlTintActive
                label.textAlignment = .center
                label.font = .main(weight: .regular, size: 11)
                label.isUserInteractionEnabled = true
                label.clipsToBounds = false

                view.addSubview(label) {
                    $0.center.equalToSuperview()
                    $0.size.equalToSuperview()
                }
            }

            view.snp.makeConstraints {
                $0.height.equalTo(ArbsUIConstants.listStackViewElementHeight)
            }
        }
    }

    // MARK: - Events

    @objc
    private func tapEvent() {
        _tapClosure?(arb)
    }
}

extension ArbsStatusCollectionViewCell: ArbsObserver {

    func arbsDidReceiveResponse(for arb: Arb) {
        onMainThread {
            self.updateUI(for: arb)
        }
    }
}
