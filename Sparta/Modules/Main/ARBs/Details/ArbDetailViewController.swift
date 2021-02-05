//
//  ArbDetailViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 21.01.2021.
//

import UIKit
import NetworkingModels

class ArbDetailViewController: BaseViewController {

    // MARK: - UI

    private var contentScrollView: UIScrollView!
    private var monthSelector: ResultMonthSelector!
    private var mainBlock: LoaderView!
    private var mainContentView: ArbDetailContentView!

    private let loaderDelay = DelayObject(delayInterval: 0.1)

    private var lastInputView: ResultKeyInputView?

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

        monthSelector = ResultMonthSelector().then { view in

            view.delegate = self

            scrollViewContent.addSubview(view) {
                $0.top.equalToSuperview()
                $0.left.right.equalToSuperview().inset(24)
                $0.height.equalTo(30)
            }
        }

        // main block view

        setupMainBlock(in: scrollViewContent, topAlignView: monthSelector)
    }

    private func setupMainBlock(in contentView: UIView, topAlignView: UIView) {

        mainBlock = LoaderView().then { view in

            view.layer.cornerRadius = 8
            view.layer.masksToBounds = true

            mainContentView = ArbDetailContentView().then { mainContentView in

                mainContentView.backgroundColor = .clear

                mainContentView.onMarginChanged { [unowned self] text in
                    self.viewModel.applyUserTarget(text)
                }

                view.addSubview(mainContentView) {
                    $0.edges.equalToSuperview()
                }
            }

            contentView.addSubview(view) {
                $0.top.equalTo(topAlignView.snp.bottom).offset(8)
                $0.left.right.equalTo(topAlignView)
                $0.bottom.equalToSuperview()
            }
        }
    }

    private func reloadMonthsData() {
        monthSelector.isEnabledLeftButton = viewModel.ableToSwitchPrevMonth
        monthSelector.isEnabledRightButton = viewModel.ableToSwitchNextMonth
        monthSelector.titleText = viewModel.formattedMonthTitle
    }
}

extension ArbDetailViewController: ArbDetailViewModelDelegate {

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

    func didLoadCells(_ cells: [ArbDetailViewModel.Cell]) {
        reloadMonthsData()
        mainContentView.applyCells(cells)
    }

    func didReloadCells(_ cells: [ArbDetailViewModel.Cell]) {
        mainContentView.reloadCells(cells)
    }
}

extension ArbDetailViewController: ResultMonthSelectorDelegate {

    func resultMonthSelectorDidTapLeftButton(view: ResultMonthSelector) {
        viewModel.switchToPrevMonth()
    }

    func resultMonthSelectorDidTapRightButton(view: ResultMonthSelector) {
        viewModel.switchToNextMonth()
    }
}
