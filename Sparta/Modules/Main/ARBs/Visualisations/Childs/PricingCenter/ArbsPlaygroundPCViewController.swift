//
//  ArbsPlaygroundPCViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.10.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers

class ArbsPlaygroundPCViewController: BaseViewController {

    // MARK: - Public properties

    var airBarTopMenu: UIView!

    // MARK: - Private properties

    private let viewModel: ArbsPlaygroundPCViewModelInterface
    private var arbsSelector: UITextFieldSelector<ArbV.Selector>!

    private var tableView: APPCTableView!

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

        // UI

        setupUI()

        // view model

        viewModel.loadData()
    }

    // MARK: - Private methods

    private func setupUI() {

        airBarTopMenu = generateAirBarTopMenu()

        let contentView = UIView().then { view in

            view.layer.cornerRadius = 13

            addSubview(view) {
                $0.top.equalToSuperview().offset(8)
                $0.left.right.bottom.equalToSuperview().inset(4)
            }
        }

        tableView = APPCTableView().then { view in

            contentView.addSubview(view) {
                $0.edges.equalToSuperview()
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
    }
}
