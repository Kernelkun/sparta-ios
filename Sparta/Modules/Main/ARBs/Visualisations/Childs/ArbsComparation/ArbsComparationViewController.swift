//
//  ArbsComparationViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.12.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers

class ArbsComparationViewController: BaseViewController {

    // MARK: - Public properties

    private(set) var airBarTopMenu: UIView!
    private(set) var airBarBottomMenu: UIView!

    // MARK: - Private properties

    private let viewModel: ArbsComparationViewModelInterface

    private var sortSegmentedView: MainSegmentedView<ArbsVACSortType>!
    private var arbsSelector: UITextFieldSelector<ArbV.Selector>!

    private var tableView: AVACTableView!

    // MARK: - Initializers

    init(viewModel: ArbsComparationViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        // view model
        viewModel.loadData()
    }

    // MARK: - Private methods

    private func setupUI() {

        airBarTopMenu = generateAirBarTopMenu()
        airBarBottomMenu = generateAirBarBottomMenu()

        let contentView = UIView().then { view in

            view.layer.cornerRadius = 13

            addSubview(view) {
                $0.top.equalToSuperview().offset(8)
                $0.left.right.bottom.equalToSuperview().inset(4)
            }
        }

        tableView = AVACTableView().then { view in

            contentView.addSubview(view) {
                $0.edges.equalToSuperview()
            }
        }
    }

    private func generateAirBarTopMenu() -> UIView {
        UIView().then { view in

            sortSegmentedView = MainSegmentedView(
                items: ArbsVACSortType.allCases,
                selectedIndex: 1 /*configurator.selectedIndexOfMenuItem*/
            ).then { segmentedView in

                segmentedView.onSelect { [unowned self] item in
//                    self.delegate?.arbVHeaderViewDidChangeSegmentedViewValue(self, item: item)
                }

                view.addSubview(segmentedView) {
                    $0.height.equalTo(32)
                    $0.left.equalToSuperview().offset(15)
                    $0.centerY.equalToSuperview()
                }
            }
        }
    }

    private func generateAirBarBottomMenu() -> UIView {
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
                    $0.left.equalToSuperview()
                    $0.centerY.equalToSuperview()
                    $0.size.equalTo(CGSize(width: 228, height: 32))
                }
            }
        }
    }
}

extension ArbsComparationViewController: ArbsComparationViewModelDelegate {

    func arbsComparationViewModelDidFetchDestinationSelectors(_ selectors: [ArbV.Selector]) {
        arbsSelector.inputValues = selectors
        arbsSelector.apply(selectedValue: selectors.first.required(), placeholder: "")
    }

    func arbsComparationViewModelDidFetchArbsVModel(_ model: ArbsComparationPCPUIModel) {
        tableView.apply(model)
    }
}
