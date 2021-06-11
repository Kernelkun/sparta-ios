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

    private var monthSelector: FreightResultMonthSelector!
    private var contentPageVC: UISliderViewController<FreightResultPageViewController>!

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
        monthSelector = FreightResultMonthSelector().then { view in

            view.backgroundColor = .clear
            view.delegate = self

            addSubview(view) {
                $0.top.equalToSuperview().offset(topBarHeight)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(45)
            }
        }

        setupPageController()
    }

    private func setupPageController() {
        let contentView = UIView().then { view in

            addSubview(view) {
                $0.left.right.bottom.equalToSuperview()
                $0.top.equalTo(monthSelector.snp.bottom)
            }
        }

        var controllers: [FreightResultPageViewController] = []
        for _ in 0..<viewModel.monthsCount {
            controllers.append(FreightResultPageViewController())
        }

        contentPageVC = UISliderViewController(controllers: controllers).then { sliderViewController in

            sliderViewController.coordinatorDelegate = self

            add(sliderViewController, to: contentView)
        }
    }
}

extension FreightResultViewController: FreightResultViewModelDelegate {

    func didChangeLoadingState(_ isLoading: Bool) {
        if isLoading {
            contentPageVC.selectedController.loaderDelay.addOperation { [weak self] in
                guard let strongSelf = self else { return }

                strongSelf.contentPageVC.selectedController.mainBlock.startAnimating()
            } 
        } else {
            contentPageVC.selectedController.mainBlock.stopAnimating()
            contentPageVC.selectedController.loaderDelay.stopAllOperations()
        }
    }

    func didCatchAnError(_ error: String) {
    }

    func didFinishCalculations(_ calculatedTypes: [FreightCalculator.CalculatedType]) {
        contentPageVC.selectedController.mainTopStackView.removeAllSubviews()
        contentPageVC.selectedController.mainBottomStackView.removeAllSubviews()

        calculatedTypes.forEach { type in

            let view = FreightResultKeyValueView()

            switch type {
            case .journeyDistance(let value):
                view.apply(key: "Journey Distance", value: value)
                contentPageVC.selectedController.mainBottomStackView.addArrangedSubview(view)

            case .journeyTime(let value):
                view.apply(key: "Journey Time", value: value)
                contentPageVC.selectedController.mainBottomStackView.addArrangedSubview(view)

            case .route(let title, let value):
                view.apply(key: title, value: value)
                contentPageVC.selectedController.mainTopStackView.addArrangedSubview(view)

            case .rate(let value):
                view.apply(key: "Rate", value: value)
                contentPageVC.selectedController.mainTopStackView.addArrangedSubview(view)

            case .cpBasis(let value):
                view.apply(key: "Basis", value: value)
                contentPageVC.selectedController.mainTopStackView.addArrangedSubview(view)

            case .marketCondition(let value):
                view.apply(key: "Market Condition", value: value)
                contentPageVC.selectedController.mainTopStackView.addArrangedSubview(view)

            case .overage(let value):
                view.apply(key: "Overage", value: value)
                contentPageVC.selectedController.mainTopStackView.addArrangedSubview(view)
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

extension FreightResultViewController: UISliderViewControllerDelegate {

    func uiSliderViewControllerDidShowController(at index: Int) {
        viewModel.switchToMonth(at: index)
    }
}

extension FreightResultViewController: FreightResultMonthSelectorDelegate {

    func freightResultMonthSelectorDidTapLeftButton(view: FreightResultMonthSelector) {
        contentPageVC.showPrevious()
    }

    func freightResultMonthSelectorDidTapRightButton(view: FreightResultMonthSelector) {
        contentPageVC.showNext()
    }
}
