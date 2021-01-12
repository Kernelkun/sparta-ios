//
//  FreightResultViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 09.01.2021.
//

import UIKit
import NetworkingModels

class FreightResultViewController: BaseViewController {

    // MARK: - UI

    private var contentScrollView: UIScrollView!
    private var monthSelector: FreightResultMonthSelector!
    private var mainBlock: LoaderView!
    private var mainTopStackView: UIStackView!
    private var mainBottomStackView: UIStackView!

    private let loaderDelay = DelayObject(delayInterval: 0.1)

    // MARK: - Private properties

    private let viewModel: FreightResultViewModel

    // MARK: - Initializers

    init(inputData: FreightCalculator.InputData) {
        viewModel = FreightResultViewModel(inputData: inputData)

        super.init(nibName: nil, bundle: nil)

        viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI

        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // navigation UI

        setupNavigationUI()

        // view model

        viewModel.loadData()
    }

    // MARK: - Private methods

    private func setupNavigationUI() {
        navigationItem.title = "Results"
        navigationBar(hide: false)
    }

    private func setupUI() {

        contentScrollView = UIScrollView().then { scrollView in

            scrollView.showsVerticalScrollIndicator = false

            addSubview(scrollView) {
                $0.top.equalToSuperview().offset(topBarHeight)
                $0.left.bottom.right.equalToSuperview()
            }
        }

        let scrollViewContent = UIView().then { view in

            view.backgroundColor = .clear

            contentScrollView.addSubview(view) {
                $0.left.top.right.equalToSuperview()
                $0.bottom.lessThanOrEqualToSuperview().priority(.high)
                $0.centerX.equalToSuperview()
            }
        }

        monthSelector = FreightResultMonthSelector().then { view in

            view.backgroundColor = .clear
            view.delegate = self

            scrollViewContent.addSubview(view) {
                $0.top.equalToSuperview()
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(45)
            }
        }

        // main block view

        setupMainBlock(in: scrollViewContent, topAlignView: monthSelector)
    }

    private func setupMainBlock(in contentView: UIView, topAlignView: UIView) {

        mainBlock = LoaderView().then { view in

            view.backgroundColor = .barBackground
            view.layer.cornerRadius = 8
            view.layer.masksToBounds = true

            mainTopStackView = UIStackView().then { stackView in

                stackView.axis = .vertical
                stackView.distribution = .equalSpacing
                stackView.spacing = 9
                stackView.alignment = .fill

                view.addSubview(stackView) {
                    $0.left.top.right.equalToSuperview().inset(8)
                }
            }

            mainBottomStackView = UIStackView().then { stackView in

                stackView.axis = .vertical
                stackView.distribution = .equalSpacing
                stackView.spacing = 9
                stackView.alignment = .fill

                view.addSubview(stackView) {
                    $0.left.bottom.right.equalToSuperview().inset(8)
                    $0.top.equalTo(mainTopStackView.snp.bottom).offset(18)
                }
            }

            contentView.addSubview(view) {
                $0.top.equalTo(topAlignView.snp.bottom).offset(8)
                $0.left.right.equalTo(topAlignView)
                $0.bottom.equalToSuperview()
            }
        }
    }
}

extension FreightResultViewController: FreightResultViewModelDelegate {

    func didChangeLoadingState(_ isLoading: Bool) {
        if isLoading {
            loaderDelay.addOperation { [weak self] in
                guard let strongSelf = self else { return }

                strongSelf.mainBlock.startAnimating()
            }
        } else {
            mainBlock.stopAnimating()
            loaderDelay.stopAllOperations()
        }
    }

    func didCatchAnError(_ error: String) {

    }

    func didFinishCalculations(_ calculatedTypes: [FreightCalculator.CalculatedType]) {

        mainTopStackView.removeAllSubviews()
        mainBottomStackView.removeAllSubviews()

        calculatedTypes.forEach { type in

            let view = FreightResultKeyValueView()

            switch type {
            case .journeyDistance(let value):
                view.apply(key: "Journey Distance", value: value)
                mainBottomStackView.addArrangedSubview(view)

            case .journeyTime(let value):
                view.apply(key: "Journey Time", value: value)
                mainBottomStackView.addArrangedSubview(view)

            case .route(let title, let value):
                view.apply(key: title, value: value)
                mainTopStackView.addArrangedSubview(view)

            case .rate(let value):
                view.apply(key: "Rate", value: value)
                mainTopStackView.addArrangedSubview(view)

            case .cpBasis(let value):
                view.apply(key: "Basis", value: value)
                mainTopStackView.addArrangedSubview(view)

            case .marketCondition(let value):
                view.apply(key: "Market Condition", value: value)
                mainTopStackView.addArrangedSubview(view)

            case .overage(let value):
                view.apply(key: "Overage", value: value)
                mainTopStackView.addArrangedSubview(view)
            }

            view.snp.makeConstraints {
                $0.height.equalTo(38)
            }
        }
    }

    func didUpdateMonthsInformation() {
        monthSelector.isEnabledLeftButton = viewModel.ableToCalculatePrevMonth
        monthSelector.isEnabledRightButton = viewModel.ableToCalculateNextMonth
        monthSelector.titleText = viewModel.formattedMonthTitle
    }
}

extension FreightResultViewController: FreightResultMonthSelectorDelegate {

    func freightResultMonthSelectorDidTapLeftButton(view: FreightResultMonthSelector) {
        viewModel.switchToPrevMonth()
    }

    func freightResultMonthSelectorDidTapRightButton(view: FreightResultMonthSelector) {
        viewModel.switchToNextMonth()
    }
}
