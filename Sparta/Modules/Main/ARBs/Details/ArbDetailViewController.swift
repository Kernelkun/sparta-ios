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
    private var mainStackView: UIStackView!

    private let loaderDelay = DelayObject(delayInterval: 0.1)

    // MARK: - Private properties

    private let arb: Arb
    private let viewModel: ArbDetailViewModel

    // MARK: - Initializers

    init(arb: Arb) {
        self.arb = arb
        viewModel = ArbDetailViewModel(arb: arb)

        super.init(nibName: nil, bundle: nil)

        arb.months.first?.dbProperties.saveUserTarget(value: 20)

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

            mainStackView = UIStackView().then { stackView in

                stackView.axis = .vertical
                stackView.distribution = .equalSpacing
                stackView.spacing = 9
                stackView.alignment = .fill

                view.addSubview(stackView) {
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

    func didLoadData() {

        // months block

        reloadMonthsData()

        // details info blocks

        mainStackView.removeAllSubviews()

        func emptyView() -> UIView {
            UIView().then { view in

                view.backgroundColor = .clear

                view.snp.makeConstraints {
                    $0.height.equalTo(15)
                }
            }
        }

        func keyValueView(title: String, value: String, color: UIColor, height: CGFloat = 38) -> ResultKeyValueView {
            ResultKeyValueView().then { view in

                view.apply(key: title, value: value, valueColor: color)

                view.snp.makeConstraints {
                    $0.height.equalTo(height)
                }
            }
        }

        func inputView(title: String, height: CGFloat = 38) -> ResultKeyInputView {
            ResultKeyInputView().then { view in

                view.apply(key: title) { [unowned self] text in
                    print("TextField text: \(text)")
                }

                view.snp.makeConstraints {
                    $0.height.equalTo(height)
                }
            }
        }

        viewModel.cells.forEach { cell in

            switch cell {
            case .emptySpace:
                mainStackView.addArrangedSubview(emptyView())

            case .target:
                mainStackView.addArrangedSubview(inputView(title: cell.displayTitle))

            case .blendCost(let value, let color), .gasNap(let value, let color),
                 .freight(let value, let color), .taArb(let value, let color),
                 .dlvPrice(let value, let color), .dlvPriceBasis(let value, let color),
                 .myMargin(let value, let color), .blenderMargin(let value, let color),
                 .fobRefyMargin(let value, let color), .cifRefyMargin(let value, let color),
                 .codBlenderMargin(let value, let color):

                mainStackView.addArrangedSubview(keyValueView(title: cell.displayTitle, value: value, color: color))
            }
        }
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
