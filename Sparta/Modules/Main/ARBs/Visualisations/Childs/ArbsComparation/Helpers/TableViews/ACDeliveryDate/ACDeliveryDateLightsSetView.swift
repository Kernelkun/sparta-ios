//
//  ACDeliveryDateLightsSetView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 30.04.2022.
//

import UIKit
import SpartaHelpers
import NetworkingModels

class ACDeliveryDateLightsSetView: TappableView {

    // MARK: - Public methods

    let arbV: ArbV
    private(set) var arbVValue: ArbV.Value?

    // MARK: - Private properties

    private var contentView: UIView!
    private var mainStackView: UIStackView!
    private var activeView: UIView!
    private var isActive: Bool = false

    private let uniqueIdentifier: Identifier<String>?
    private var margins: [ArbV.Margin]?

    // MARK: - Initializers

    init(
        arbV: ArbV,
        arbVValue: ArbV.Value?,
        uniqueIdentifier: Identifier<String>?,
        isActive: Bool
    ) {
        self.arbV = arbV
        self.uniqueIdentifier = uniqueIdentifier
        self.margins = arbVValue?.margins
        self.arbVValue = arbVValue
        super.init(frame: .zero)

        setupUI()
        updateUI()
        setIsActive(isActive, animated: false)

        // observe for sockets

        if let uniqueIdentifier = uniqueIdentifier {
            observeArbsVis(for: uniqueIdentifier)
        }
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    deinit {
        stopObservingAllArbsVisEvents()
    }

    // MARK: - Public methods

    func setIsActive(_ isActive: Bool, animated: Bool) {
        self.isActive = isActive

        let duration = animated ? 0.1 : 0.0
        let alpha = isActive ? 1.0 : 0.0
        let transform: CGAffineTransform = isActive ? .init(scaleX: 0.97, y: 0.95) : .identity

        UIView.animate(withDuration: duration) {
            self.activeView.alpha = alpha
            self.mainStackView.transform = transform
        }
    }

    // MARK: - Private methods

    private func setupUI() {
        mainStackView = UIStackView().then { stackView in

            stackView.axis = .vertical
            stackView.distribution = .fill
            stackView.spacing = APPCUIConstants.priceItemsLineSpace
            stackView.alignment = .fill

            addSubview(stackView) {
                $0.edges.equalToSuperview()
            }
        }

        activeView = UIView().then { view in

            view.layer.borderColor = UIColor.controlTintActive.cgColor
            view.layer.borderWidth = 2
            view.layer.cornerRadius = 6
            view.alpha = 0

            addSubview(view) {
                $0.edges.equalToSuperview().inset(-2)
            }
        }
    }

    private func updateUI() {
        mainStackView.removeAllSubviews()

        func generateLightView(_ model: ColoredNumber?) -> ACDeliveryDateTableLightView {
            ACDeliveryDateTableLightView().then { view in

                var state: ACDeliveryDateTableLightView.State = .inactive

                if let model = model {
                    state = .active(color: model.valueColor, text: model.value)
                }

                view.state = state

                view.snp.makeConstraints {
                    $0.size.equalTo(CGSize(width: 65, height: 50))
                }
            }
        }

        var model: ColoredNumber?

        if let arbVValue = arbVValue {
            model = ColoredNumber(value: arbVValue.deliveredPrice.displayedValue,
                                  color: "red")
        }

        mainStackView.addArrangedSubview(generateLightView(model))
    }
}

extension ACDeliveryDateLightsSetView: ArbsVisSyncObserver {

    func arbsVisSyncManagerDidReceiveArbMonth(manager: ArbsVisSyncInterface, arbVMonth: ArbVMonthSocket) {
        guard let uniqueIdentifier = uniqueIdentifier,
              arbVMonth.uniqueIdentifier == uniqueIdentifier else { return }

        self.margins = arbVMonth.margins
        self.updateUI()
    }
}

