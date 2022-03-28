//
//  APPCTableView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.10.2021.
//

import UIKit
import NetworkingModels

class APPCTableView: UIView {

    // MARK: - UI

    private var titleLabel: UILabel!
    private var model: ArbsPlaygroundPCPUIModel!

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Public methods

    func apply(_ model: ArbsPlaygroundPCPUIModel) {
        self.model = model
        updateUI()
    }

    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = .clear
        tintColor = .controlTintActive
    }

    private func updateUI() {
        removeAllSubviews()

        func generateLabel(with title: String) -> UILabel {
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

        let scrollView = UIScrollView().then { view in

            view.backgroundColor = .clear
            view.showsHorizontalScrollIndicator = false
            view.showsVerticalScrollIndicator = false
            view.bounces = false
            view.clipsToBounds = false
//            view.contentSize = scrollViewContentSize()

                addSubview(view) {
                    $0.left.equalToSuperview().offset(APPCUIConstants.leftMenuWidth)
                    $0.top.bottom.equalToSuperview()
                    $0.right.equalToSuperview().inset(8)
                }
        }

        let scrollViewContent = UIView().then { view in

            view.backgroundColor = UIColor.red.withAlphaComponent(0.1)
            view.clipsToBounds = false

            scrollView.addSubview(view) {
                $0.left.top.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.right.lessThanOrEqualToSuperview().priority(.high)
//                $0.centerY.equalToSuperview()
            }
        }

        let datesHeaderView = APPCDatesHeaderView(headers: model.headers).then { view in

            scrollViewContent.addSubview(view) {
                $0.left.top.equalToSuperview()
            }
        }

        var prevStackView: UIStackView?
        var prevLineView: UIView?

        for (index, arbV) in model.arbsV.enumerated() {

            let identifierView = APPCIdentifierView(
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

            let leftContentView = UIView().then { view in

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

                func makeUnactiveViews() {
                    stackView.arrangedSubviews.forEach { view in
                        guard let view = view as? APPCLightsSetView else { return }
                        view.isActive = false
                    }
                }

                self.model.headers.forEach { header in
                    guard let value = arbV.values.first(where: { $0.deliveryMonth == header.month.title }) else { return }

                    let margins = value.margins
                    let uniqueIdentifier = arbV.uniqueIdentifier(from: value)

                    _ = APPCLightsSetView(margins: margins, uniqueIdentifier: uniqueIdentifier).then { view in

                        view.onTap { view in
                            guard let view = view as? APPCLightsSetView else { return }

                            makeUnactiveViews()
                            view.isActive = true
                        }

                        stackView.addArrangedSubview(view)
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

        // identifier view

        /*let identifierView = APPCIdentifierView(
            title: "ARA", //arbV.loadRegion.uppercased(),
            subTitle: "LR1" //arbV.vesselType.uppercased()
        )

        // fetch categories

        // end of fetching categories

        // labels



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

        let leftContentView = UIView().then { view in

            view.addSubview(identifierView) {
                $0.top.equalToSuperview().offset(8)
                $0.left.equalToSuperview().offset(8)
                $0.size.equalTo(CGSize(width: 50, height: 38))
            }

            view.addSubview(labelsStackView) {
                $0.left.equalTo(identifierView.snp.right).offset(8)
                $0.bottom.equalToSuperview()
                $0.top.equalToSuperview().offset(8)
                $0.right.equalToSuperview().inset(8)
            }

            contentView.addSubview(view) {
                $0.top.left.equalToSuperview()
                $0.bottom.equalToSuperview().inset(16)
                $0.width.equalTo(APPCUIConstants.leftMenuWidth)
            }
        }

        /// mains views

        // dates view*/
    }

    private func clearUI() {
//        contentView.removeAllSubviews()
    }
}
