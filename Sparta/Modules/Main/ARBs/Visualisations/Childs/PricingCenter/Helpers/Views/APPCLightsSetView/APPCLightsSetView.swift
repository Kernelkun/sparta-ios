//
//  APPCLightsSetView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.10.2021.
//

import UIKit
import SpartaHelpers
import NetworkingModels

class APPCLightsSetView: TappableView {

    // MARK: - Public methods

    var isActive: Bool {
        didSet { updateActiveStateUI() }
    }

    // MARK: - Private properties

    private var contentView: UIView!
    private var mainStackView: UIStackView!
    private var activeView: UIView?

    private let uniqueIdentifier: String
    private var margins: [ArbV.Margin]? = []

    // MARK: - Initializers

    init(margins: [ArbV.Margin]?, uniqueIdentifier: String) {
        self.margins = margins
        self.uniqueIdentifier = uniqueIdentifier
        self.isActive = false
        super.init(frame: .zero)

        setupUI()
        updateUI()
        updateActiveStateUI()

        // observe for sockets

        observeArbsVis(for: uniqueIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    deinit {
        stopObservingAllArbsVisEvents()
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

    private func updateActiveStateUI() {
        if isActive {
            activeView = UIView().then { view in
                view.layer.borderColor = UIColor.controlTintActive.cgColor
                view.layer.borderWidth = 2
                view.layer.cornerRadius = 6
                view.frame = self.bounds.insetBy(dx: -2, dy: -2)
                addSubview(view)
            }

            mainStackView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } else {
            activeView?.removeFromSuperview()
            mainStackView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}

extension APPCLightsSetView: ArbsVisSyncObserver {

    func arbsVisSyncManagerDidReceiveArbMonth(manager: ArbsVisSyncInterface, arbVMonth: ArbVMonthSocket) {
        guard arbVMonth.uniqueIdentifier == uniqueIdentifier else { return }

        self.margins = arbVMonth.margins
        self.updateUI()
        self.isActive = true
    }
}
