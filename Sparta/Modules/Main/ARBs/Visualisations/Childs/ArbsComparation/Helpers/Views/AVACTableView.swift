//
//  AVACTableView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 31.03.2022.
//

import UIKit
import NetworkingModels
import SpartaHelpers

class AVACTableView: UIView {

    // MARK: - UI

    private var titleLabel: UILabel!
    private var model: ArbsComparationPCPUIModel!
    private var lightSetViews: [AVACLightsSetView] = []

    // MARK: - Private properties

    private var _onChooseClosure: TypeClosure<ArbV.Value>?

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Public methods

    func apply(_ model: ArbsComparationPCPUIModel) {
        self.model = model
        updateUI()
    }

    func onChoose(completion: @escaping TypeClosure<ArbV.Value>) {
        _onChooseClosure = completion
    }

    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = .clear
        tintColor = .controlTintActive
    }

    private func updateUI() {
        removeAllSubviews()
        lightSetViews = []

        let scrollView = UIScrollView().then { view in

            view.backgroundColor = .clear
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

//        APPCDatesHeaderView(headers: model.headers)
        let datesHeaderView = UIView().then { view in

            scrollViewContent.addSubview(view) {
                $0.left.top.equalToSuperview()
                $0.height.equalTo(58) // need to remove
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

                    let isActive: Bool = uniqueIdentifier == self.model.selectedValueIdentifier

                    _ = AVACLightsSetView(
                        arbVValue: value,
                        uniqueIdentifier: uniqueIdentifier,
                        isActive: isActive
                    ).then { view in

                        view.onTap { [unowned self] view in
                            guard let view = view as? APPCLightsSetView, let arbVValue = view.arbVValue else { return }

                            makeInactiveSetViews()
                            view.setIsActive(true, animated: true)
                            _onChooseClosure?(arbVValue)
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
//        contentView.removeAllSubviews()
    }
}

