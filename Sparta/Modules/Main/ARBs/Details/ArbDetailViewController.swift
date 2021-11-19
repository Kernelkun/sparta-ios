//
//  ArbDetailViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 21.01.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers

class ArbDetailViewController: BaseViewController {

    // MARK: - UI

    private var monthSelector: ResultMonthSelector!
    private var contentPageVC: UISliderViewController<ArbDetailPageViewController>!

    // MARK: - Private properties

    private let arb: Arb
    private let viewModel: ArbDetailViewModel

    // MARK: - Initializers

    init(arb: Arb) {
        self.arb = arb
        viewModel = ArbDetailViewModel(arb: arb)

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
        navigationItem.title = arb.grade
        navigationBar(hide: false)
    }

    private func setupUI() {
        monthSelector = ResultMonthSelector().then { view in

            view.delegate = self

            addSubview(view) {
                $0.top.equalToSuperview().offset(topBarHeight + 8)
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(39)
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

        let controllers = arb.months.compactMap { _ -> ArbDetailPageViewController in
            let viewController = ArbDetailPageViewController()
            viewController.delegate = self
            return viewController
        }

        contentPageVC = UISliderViewController(controllers: controllers).then { sliderViewController in

            sliderViewController.coordinatorDelegate = self

            add(sliderViewController, to: contentView)
        }
    }

    private func reloadMonthsData() {
        monthSelector.isEnabledLeftButton = viewModel.ableToSwitchPrevMonth
        monthSelector.isEnabledRightButton = viewModel.ableToSwitchNextMonth
        monthSelector.titleText = viewModel.formattedMonthTitle
    }
}

extension ArbDetailViewController: UISliderViewControllerDelegate {

    func uiSliderViewControllerDidShowController(at index: Int) {
        viewModel.switchToMonth(at: index)
    }
}

extension ArbDetailViewController: ResultMonthSelectorDelegate {

    func resultMonthSelectorDidTapLeftButton(view: ResultMonthSelector) {
        contentPageVC.showPrevious()
    }

    func resultMonthSelectorDidTapRightButton(view: ResultMonthSelector) {
        contentPageVC.showNext()
    }
}

extension ArbDetailViewController: ArbDetailPageViewControllerDelegate {

    func arbDetailPageViewControllerDidChangeMargin(_ controller: ArbDetailPageViewController, margin: String) {
        viewModel.applyUserTarget(margin)
    }
}

extension ArbDetailViewController: ArbDetailViewModelDelegate {

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

    func didLoadCells(_ cells: [ArbDetailViewModel.Cell]) {
        reloadMonthsData()
        contentPageVC.selectedController.mainContentView.applyCells(cells)
    }

    func didReloadCells(_ cells: [ArbDetailViewModel.Cell]) {
        contentPageVC.selectedController.mainContentView.reloadCells(cells)
    }
}
