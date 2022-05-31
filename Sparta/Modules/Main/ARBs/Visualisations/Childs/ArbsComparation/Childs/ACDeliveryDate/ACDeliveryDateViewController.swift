//
//  ACDeliveryDateViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.04.2022.
//

import UIKit
import NetworkingModels

class ACDeliveryDateViewController: BaseViewController, ACChildControllerInterface {

    // MARK: - Public properties

    private(set) var bottomAirBarContentView: UIView

    // MARK: - Private properties

    private let viewModel: ACDeliveryDateViewModelInterface

    private var tableView: ACDeliveryDateTableView!
    private var tradeChartVC: ACWebTradeViewController!

    private var monthSelector: ResultMonthSelector!
    private var portfoliosSelector: UITextFieldSelector<Arb.Portfolio>!

    // MARK: - Initializers

    init(viewModel: ACDeliveryDateViewModelInterface) {
        self.viewModel = viewModel
        self.bottomAirBarContentView = UIView()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI

        setupUI()

        // view model

        viewModel.loadData()
    }

    // MARK: - Private methods
    
    private func setupUI() {
        tableView = ACDeliveryDateTableView().then { view in

            view.onChoose { [unowned self] activeModel in
//                viewModel.makeActiveModel(activeModel)
            }

            addSubview(view) {
                $0.left.top.right.equalToSuperview()
            }
        }

        let tradeChartContentView = UIView().then { view in

            tradeChartVC = ACWebTradeViewController(edges: .zero)
//            tradeChartVC.delegate = self
            add(tradeChartVC, to: view)

            addSubview(view) {
                $0.top.equalTo(tableView.snp.bottom).offset(8)
                $0.height.equalTo(302)
                $0.left.bottom.right.equalToSuperview()
            }
        }

        bottomAirBarContentView = UIView().then { view in

            monthSelector = ResultMonthSelector().then { view in

                view.delegate = self

                view.snp.makeConstraints {
                    $0.size.equalTo(CGSize(width: 229, height: 32))
                }
            }

            let itemsFieldConfigurator = UITextFieldSelectorConfigurator(
                leftSpace: 10,
                imageRightSpace: 11,
                imageLeftSpace: 3,
                cornerRadius: 10,
                defaultTextAttributes: [NSAttributedString.Key.foregroundColor: UIColor.primaryText,
                                        NSAttributedString.Key.font: UIFont.main(weight: .regular, size: 18)]
            )

            portfoliosSelector = UITextFieldSelector(configurator: itemsFieldConfigurator).then { selector in

                selector.onChooseValue { [unowned self] arbVSelector in
//                    viewModel.makeActiveArbVSelector(arbVSelector)
                }

                selector.snp.makeConstraints {
                    $0.size.equalTo(CGSize(width: 228, height: 32))
                }
            }

            _ = UIStackView().then { stackView in

                stackView.alignment = .leading
                stackView.spacing = 15
                stackView.axis = .horizontal

                stackView.addArrangedSubview(monthSelector)
                stackView.addArrangedSubview(portfoliosSelector)

                view.addSubview(stackView) {
                    $0.left.equalToSuperview()
                    $0.centerY.equalToSuperview()
                }
            }
        }
    }
}

extension ACDeliveryDateViewController: ResultMonthSelectorDelegate {
    
    func resultMonthSelectorDidTapLeftButton(view: ResultMonthSelector) {
        viewModel.switchToPrevMonth()
    }

    func resultMonthSelectorDidTapRightButton(view: ResultMonthSelector) {
        viewModel.switchToNextMonth()
    }
}

extension ACDeliveryDateViewController: ACDeliveryDateViewModelDelegate {

    func acDeliveryDateViewModelDidChangeLoadingState(_ isLoading: Bool) {
    }

    func acDeliveryDateViewModelDidCatchAnError(_ error: String) {
    }

    func acDeliveryDateViewModelDidFetchPortfolios(_ portfolios: [Arb.Portfolio]) {
        portfoliosSelector.inputValues = portfolios
        portfoliosSelector.apply(selectedValue: portfolios.first.required(), placeholder: "")
    }

    func acDeliveryDateViewModelDidFetchMonthsSelector(_ selector: MonthsSelector) {
        monthSelector.isEnabledLeftButton = selector.ableSwitchToPrevMonth
        monthSelector.isEnabledRightButton = selector.ableSwitchToNextMonth
        monthSelector.titleText = selector.month
    }

    func acDeliveryDateViewModelDidFetchArbsVModel(_ model: ACDeliveryDateUIModel) {
        tableView.apply(model)
    }
}
