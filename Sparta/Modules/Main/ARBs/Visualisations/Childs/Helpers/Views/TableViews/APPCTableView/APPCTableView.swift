//
//  APPCTableView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.10.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers

class APPCTableView: UIView {

    // MARK: - UI

    private var titleLabel: UILabel!
    private var model: ArbsPlaygroundPCPUIModel!
    private var lightSetViews: [APPCLightsSetView] = []

    // MARK: - Private properties

    private var _onChooseClosure: TypeClosure<ArbsPlaygroundPCPUIModel.Active>?

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Public methods

    func apply(_ model: ArbsPlaygroundPCPUIModel) {
        self.model = model
        updateUI()
    }

    func onChoose(completion: @escaping TypeClosure<ArbsPlaygroundPCPUIModel.Active>) {
        _onChooseClosure = completion
    }

    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = .neutral85
        layer.cornerRadius = 13
    }

    private func updateUI() {
        clearUI()

        let scrollView = UIScrollView().then { view in
            view.showsHorizontalScrollIndicator = false
            view.showsVerticalScrollIndicator = false
            view.bounces = false
            view.clipsToBounds = false

                addSubview(view) {
                    $0.left.equalToSuperview().offset(APPCUIConstants.leftMenuWidth)
                    $0.top.bottom.equalToSuperview()
                    $0.right.equalToSuperview().inset(8)
                }
        }

        let scrollViewContent = UIView().then { view in

            view.backgroundColor = .clear
            view.clipsToBounds = false

            scrollView.addSubview(view) {
                $0.left.top.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.right.lessThanOrEqualToSuperview().priority(.high)
            }
        }

        let headers = model.headers.compactMap { AVDatesHeaderView.Header(title: $0.month.title, subTitle: $0.units) }
        let configurator = AVDatesHeaderView.Configurator(
            headers: headers,
            itemWidth: 70,
            itemSpace: AVACUIConstants.priceItemSpace - 2
        )
        let datesHeaderView = AVDatesHeaderView(configurator: configurator).then { view in

            scrollViewContent.addSubview(view) {
                $0.left.top.equalToSuperview()
            }
        }

        var prevStackView: UIStackView?
        var prevLineView: UIView?

        for (index, arbV) in model.arbsV.enumerated() {

            let identifierView = AVTableIdentifierView(
                title: arbV.loadRegion.uppercased(),
                subTitle: arbV.vesselType.uppercased()
            )

            let labelsStackView = UIStackView().then { stackView in

                stackView.axis = .vertical
                stackView.distribution = .equalSpacing
                stackView.spacing = APPCUIConstants.priceItemsLineSpace
                stackView.alignment = .fill

                if let firstValue = arbV.values.first {
                    firstValue.margins.forEach { margin in
                        stackView.addArrangedSubview(generateLabel(with: margin.type))
                    }
                }
            }

            _ = UIView().then { view in

                view.addSubview(identifierView) {
                    $0.top.equalToSuperview()
                    $0.left.equalToSuperview().offset(8)
                    $0.size.equalTo(CGSize(width: 50, height: 38))
                }

                view.addSubview(labelsStackView) {
                    $0.left.equalTo(identifierView.snp.right).offset(8)
                    $0.bottom.equalToSuperview()
                    $0.top.equalToSuperview()
                    $0.right.equalToSuperview().inset(8)
                }

                addSubview(view) {

                    if let prevLineView = prevLineView {
                        $0.top.equalTo(prevLineView.snp.bottom).offset(20)
                    } else {
                        $0.top.equalToSuperview().offset(58)
                    }

                    if index == (self.model.arbsV.count - 1) {
                        $0.bottom.equalToSuperview().inset(16)
                    }

                    $0.left.equalToSuperview()
                    $0.width.equalTo(APPCUIConstants.leftMenuWidth)
                }
            }

            // light views

            let numbersStackView = UIStackView().then { stackView in

                stackView.axis = .horizontal
                stackView.distribution = .fillEqually
                stackView.spacing = APPCUIConstants.priceItemSpace
                stackView.alignment = .fill

                self.model.headers.forEach { header in
                    let value = arbV.values.first(where: { $0.deliveryMonth == header.month.title })
                    let uniqueIdentifier: Identifier<String>?

                    if let value = value {
                        uniqueIdentifier = arbV.uniqueIdentifier(from: value)
                    } else {
                        uniqueIdentifier = nil
                    }

                    let isActive: Bool = uniqueIdentifier == self.model.active.identifier

                    _ = APPCLightsSetView(
                        arbV: arbV,
                        arbVValue: value,
                        uniqueIdentifier: uniqueIdentifier,
                        isActive: isActive
                    ).then { view in

                        view.onTap { [unowned self] view in
                            guard let view = view as? APPCLightsSetView,
                                    let arbV = view.arbV,
                                    let arbVValue = view.arbVValue else { return }

                            makeInactiveSetViews()
                            view.setIsActive(true, animated: true)
                            _onChooseClosure?(ArbsPlaygroundPCPUIModel.Active(arbV: arbV, arbVValue: arbVValue))
                        }

                        stackView.addArrangedSubview(view)
                        lightSetViews.append(view)
                    }
                }

                scrollViewContent.addSubview(stackView) {

                    if let prevLineView = prevLineView {
                        $0.top.equalTo(prevLineView.snp.bottom).offset(20)
                    } else {
                        $0.top.equalTo(datesHeaderView.snp.bottom)
                    }

                    if index == (self.model.arbsV.count - 1) {
                        $0.bottom.equalToSuperview().inset(16)
                        $0.right.equalToSuperview()
                    }

                    $0.left.equalToSuperview()
                }
            }

            prevStackView = numbersStackView

            // draw line

            if index != (self.model.arbsV.count - 1),
                self.model.arbsV.count > 1,
                let prevStackView = prevStackView {
                
                let lineView = UIView().then { view in

                    view.backgroundColor = .gray

                    scrollViewContent.addSubview(view) {
                        $0.height.equalTo(1)
                        $0.left.right.equalToSuperview()
                        $0.top.equalTo(prevStackView.snp.bottom).offset(20)
                    }
                }

                prevLineView = lineView
            }
        }
    }

    private func generateLabel(with title: String) -> UILabel {
        UILabel().then { label in

            label.text = title
            label.textAlignment = .right
            label.textColor = .primaryText
            label.font = .main(weight: .regular, size: 11)
            label.numberOfLines = 0

            label.snp.makeConstraints {
                $0.height.equalTo(40)
            }
        }
    }

    func makeInactiveSetViews() {
        lightSetViews.forEach { $0.setIsActive(false, animated: true) }
    }

    private func clearUI() {
        removeAllSubviews()
        lightSetViews = []
    }
}
