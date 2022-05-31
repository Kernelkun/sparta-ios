//
//  ACDestinationViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.04.2022.
//

import UIKit
import NetworkingModels

class ACDestinationViewController: BaseViewController, ACChildControllerInterface {

    // MARK: - Public properties

    private(set) var bottomAirBarContentView: UIView

    // MARK: - Private properties

    private let viewModel: ACDestinationViewModelInterface

    private var arbsSelector: UITextFieldSelector<ArbV.Selector>!
    private var tableView: ACDestinationTableView!
    private var tradeChartVC: ACWebTradeViewController!

    // MARK: - Initializers

    init(viewModel: ACDestinationViewModelInterface) {
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

        // load data

        viewModel.loadData()
    }

    // MARK: - Private methods

    private func setupUI() {
        tableView = ACDestinationTableView().then { view in

            view.onChoose { [unowned self] activeModel in
                viewModel.makeActiveModel(activeModel)
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

        bottomAirBarContentView.do { view in
        
            view.backgroundColor = .clear

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
                    $0.left.equalToSuperview()
                    $0.centerY.equalToSuperview()
                    $0.size.equalTo(CGSize(width: 228, height: 32))
                }
            }
        }
    }
}

extension ACDestinationViewController: ACDestinationViewModelDelegate {

    func acDestinationViewModelDidChangeLoadingState(_ isLoading: Bool) {

    }

    func acDestinationViewModelDidFetchDestinationSelectors(_ selectors: [ArbV.Selector]) {
        arbsSelector.inputValues = selectors
        arbsSelector.apply(selectedValue: selectors.first.required(), placeholder: "")
    }

    func acDestinationViewModelDidFetchArbsVModel(_ model: ArbsComparationPCPUIModel) {
        tableView.apply(model)
    }

    func acDestinationViewModelDidChangeActiveArbVValue(_ model: ArbsComparationPCPUIModel) {

    }
}
