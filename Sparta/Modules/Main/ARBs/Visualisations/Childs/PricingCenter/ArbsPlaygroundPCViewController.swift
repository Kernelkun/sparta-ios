//
//  ArbsPlaygroundPCViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.10.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers

protocol ArbsPlaygroundPCActionDelegate: AnyObject {
    func arbsPlaygroundPCViewControllerDidChangeContentOffset(
        _ viewController: ArbsPlaygroundPCViewController,
        offset: CGFloat,
        direction: MovingDirection
    )
}

class ArbsPlaygroundPCViewController: BaseViewController {

    // MARK: - Public properties

    var airBarTopMenu: UIView!
    weak var actionsDelegate: ArbsPlaygroundPCActionDelegate?

    // MARK: - Private properties

    private let viewModel: ArbsPlaygroundPCViewModelInterface
    private var arbsSelector: UITextFieldSelector<ArbV.Selector>!

    private var tableView: APPCTableView!
    private var tradeChartVC: ACWebTradeViewController!

    // MARK: - Initializers

    init(viewModel: ArbsPlaygroundPCViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        // UI

        setupUI()

        // view model

        viewModel.loadData()
    }

    // MARK: - Private methods

    private func setupUI() {

        airBarTopMenu = generateAirBarTopMenu()

        let contentView = UIView().then { view in

            addSubview(view) {
                $0.edges.equalToSuperview()
            }
        }

        tableView = APPCTableView().then { view in

            view.onChoose { [unowned self] activeModel in
                self.viewModel.makeActiveModel(activeModel)
            }

            contentView.addSubview(view) {
                $0.left.top.right.equalToSuperview()
            }
        }

        let tradeChartContentView = UIView().then { view in

            tradeChartVC = ACWebTradeViewController(edges: .zero)
            tradeChartVC.delegate = self
            add(tradeChartVC, to: view)

            contentView.addSubview(view) {
                $0.top.equalTo(tableView.snp.bottom).offset(8)
                $0.height.equalTo(302)
                $0.left.bottom.right.equalToSuperview()
            }
        }
    }

    private func generateAirBarTopMenu() -> UIView {
        UIView().then { view in

            let itemsFieldConfigurator = UITextFieldSelectorConfigurator(
                leftSpace: 10,
                imageRightSpace: 11,
                imageLeftSpace: 3,
                cornerRadius: 10,
                defaultTextAttributes: [NSAttributedString.Key.foregroundColor: UIColor.primaryText,
                                        NSAttributedString.Key.font: UIFont.main(weight: .regular, size: 18)]
            )

            arbsSelector = UITextFieldSelector(configurator: itemsFieldConfigurator).then { selector in

                selector.onChooseValue { [unowned self] arbVSelector in
                    viewModel.makeActiveArbVSelector(arbVSelector)
                }

                view.addSubview(selector) {
                    $0.left.equalToSuperview().offset(15)
                    $0.centerY.equalToSuperview()
                    $0.size.equalTo(CGSize(width: 228, height: 32))
                }
            }
        }
    }

    private func loadHistoricalChart(_ model: ArbsPlaygroundPCPUIModel) {
        let configurator = ACWebTradeViewController.Configurator(
            arbIds: model.arbsV.compactMap { $0.arbId },
            dateRange: .month,
            deliveryWindow: nil,
            deliveryMonth: model.active.month
        )
        tradeChartVC.load(configurator: configurator)
    }
}

extension ArbsPlaygroundPCViewController: ACWebTradeViewDelegate {

    func acWebTradeViewControllerDidChangeContentOffset(_ viewController: ACWebTradeViewController, offset: CGFloat, direction: MovingDirection) {
        actionsDelegate?.arbsPlaygroundPCViewControllerDidChangeContentOffset(
            self,
            offset: offset,
            direction: direction
        )
    }

    func acWebTradeViewControllerDidTapOnHLView(_ viewController: ACWebTradeViewController) {
    }

    func acWebTradeViewControllerDidChangeOrientation(_ viewController: ACWebTradeViewController, interfaceOrientation: UIInterfaceOrientation) {
    }
}

extension ArbsPlaygroundPCViewController: ArbsPlaygroundPCViewModelDelegate {

    func arbsPlaygroundPCViewModelDidChangeLoadingState(_ isLoading: Bool, module: ArbsPlaygroundPCLoadingModule) {
    }

    func arbsPlaygroundPCViewModelDidFetchSelectors(_ selectors: [ArbV.Selector]) {
        arbsSelector.inputValues = selectors
        arbsSelector.apply(selectedValue: selectors.first.required(), placeholder: "")
    }

    func arbsPlaygroundPCViewModelDidFetchArbsVModel(_ model: ArbsPlaygroundPCPUIModel) {
        tableView.apply(model)
        loadHistoricalChart(model)
    }

    func arbsPlaygroundPCViewModelDidChangeActiveArbVValue(_ model: ArbsPlaygroundPCPUIModel) {
        loadHistoricalChart(model)
    }
}
