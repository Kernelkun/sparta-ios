//
//  APPCLightsSetView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.10.2021.
//

import UIKit
import NetworkingModels

class APPCLightsSetView: UIView {

    // MARK: - Private properties

    private var contentView: UIView!
    private var mainStackView: UIStackView!

    private var margins: [ArbV.Margin]? = []

    // MARK: - Initializers

    init(margins: [ArbV.Margin]?) {
        self.margins = margins
        super.init(frame: .zero)

        setupUI()
        updateUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
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
    }

    private func updateUI() {
        mainStackView.removeAllSubviews()

        func generateLightView(_ model: ColoredNumber?) -> APPCLightView {
            APPCLightView().then { view in

                var state: APPCLightView.State = .inactive

                if let model = model {
                    state = .active(color: model.valueColor, text: model.value)
                }

                view.state = state

                view.snp.makeConstraints {
                    $0.size.equalTo(CGSize(width: 70, height: 40))
                }
            }
        }

        if let margins = margins {
            margins.forEach { mainStackView.addArrangedSubview(generateLightView($0.price)) }
        } else {
            mainStackView.addArrangedSubview(generateLightView(nil))
        }
    }
}
