//
//  ACDeliveryDateTableView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 29.04.2022.
//

import UIKit
import NetworkingModels
import SpartaHelpers

class ACDeliveryDateTableView: UIView {

    // MARK: - UI

    private var titleLabel: UILabel!
    private var model: ACDeliveryDateUIModel!
    private var lightSetViews: [ACDeliveryDateLightsSetView] = []

    // MARK: - Private properties

    private var _onChooseClosure: TypeClosure<ArbsComparationPCPUIModel.Active>?

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Public methods

    func apply(_ model: ACDeliveryDateUIModel) {
        self.model = model
        updateUI()
    }

    func onChoose(completion: @escaping TypeClosure<ArbsComparationPCPUIModel.Active>) {
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

            view.backgroundColor = .clear
            view.showsHorizontalScrollIndicator = false
            view.showsVerticalScrollIndicator = false
            view.bounces = false
            view.clipsToBounds = false

            addSubview(view) {
                $0.left.equalToSuperview().offset(AVACUIConstants.leftMenuWidth + 8)
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

        let headers = model.headers.compactMap { AVDatesHeaderView.Header(title: $0.title, subTitle: $0.units) }
        let configurator = AVDatesHeaderView.Configurator(
            headers: headers,
            itemWidth: 85,
            itemSpace: APPCUIConstants.priceItemSpace + 2
        )
        let datesHeaderView = AVDatesHeaderView(configurator: configurator).then { view in

            scrollViewContent.addSubview(view) {
                $0.left.top.equalToSuperview()
            }
        }

        var prevStackView: UIStackView?

        for (index, row) in model.rows.enumerated() {

            let identifierView = UILabel().then { label in

                label.textColor = .primaryText
                label.textAlignment = .center
                label.font = .main(weight: .medium, size: 14)
                label.text = row.title
            }

            _ = UIView().then { view in

                view.backgroundColor = .red

                view.addSubview(identifierView) {
                    $0.centerY.equalToSuperview()
                    $0.left.equalToSuperview().offset(4)
                    $0.size.equalTo(CGSize(width: 42, height: 65))
                }

                addSubview(view) {

                    if let prevStackView = prevStackView {
                        $0.top.equalTo(prevStackView.snp.bottom).offset(8)
                    } else {
                        $0.top.equalToSuperview().offset(58)
                    }

                    if index == (self.model.rows.count - 1) {
                        $0.bottom.equalToSuperview().inset(16)
                    }

                    $0.left.equalToSuperview()
                    $0.width.equalTo(AVACUIConstants.leftMenuWidth)
                    $0.height.equalTo(50)
                }
            }

            // light views

            let numbersStackView = UIStackView().then { stackView in

                stackView.axis = .horizontal
                stackView.distribution = .fillEqually
                stackView.spacing = AVACUIConstants.priceItemSpace
                stackView.alignment = .fill

                self.model.headers.forEach { header in
                    /*let value = row.groups.first(where: { $0.grade == header.title })?.arbsV.first?.values.first(where: { $0.deliveryMonth == header.month.title })
                    let uniqueIdentifier: Identifier<String>?

                    if let value = value {
                        uniqueIdentifier = arbV.uniqueIdentifier(from: value)
                    } else {
                        uniqueIdentifier = nil
                    }

                    let isActive: Bool = uniqueIdentifier == self.model.active.identifier

                    _ = ACDeliveryDateLightsSetView(
                        arbV: arbV,
                        arbVValue: value,
                        uniqueIdentifier: uniqueIdentifier,
                        isActive: isActive
                    ).then { view in

                        view.onTap { [unowned self] view in
                            guard let view = view as? ACDeliveryDateLightsSetView, let arbVValue = view.arbVValue else { return }

                            makeInactiveSetViews()
                            view.setIsActive(true, animated: true)
                            _onChooseClosure?(ArbsComparationPCPUIModel.Active(arbV: view.arbV, arbVValue: arbVValue))
                        }

                        stackView.addArrangedSubview(view)
                        lightSetViews.append(view)
                    }*/
                }

                scrollViewContent.addSubview(stackView) {

                    if let prevStackView = prevStackView {
                        $0.top.equalTo(prevStackView.snp.bottom).offset(8)
                    } else {
                        $0.top.equalTo(datesHeaderView.snp.bottom)
                    }

                    if index == (self.model.rows.count - 1) {
                        $0.right.equalToSuperview()
                        $0.bottom.equalToSuperview().inset(16)
                    }

                    $0.left.equalToSuperview()
                }
            }

            prevStackView = numbersStackView
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

