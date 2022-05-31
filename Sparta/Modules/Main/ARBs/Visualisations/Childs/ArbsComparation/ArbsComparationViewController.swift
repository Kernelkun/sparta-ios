//
//  ArbsComparationViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.12.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers

protocol ArbsComparationActionDelegate: AnyObject {
    func arbsComparationViewControllerDidChangeContentOffset(
        _ viewController: ArbsComparationViewController,
        offset: CGFloat,
        direction: MovingDirection
    )
}

class ArbsComparationViewController: BaseViewController {

    // MARK: - Public properties

    private(set) var airBarTopMenu: UIView!
    private(set) var airBarBottomMenu: UIView!

    weak var actionsDelegate: ArbsComparationActionDelegate?

    // MARK: - Private properties

    private let viewModel: ArbsComparationViewModelInterface

    private var sortSegmentedView: MainSegmentedView<ArbsVACSortType>!
    

    private var activeController: ACChildControllerInterface?

    private var airBarBottomContentView: UIView!

    // MARK: - Wireframes

    private var acDestinationVC: ACChildControllerInterface?
    private var acDeliveryDateVC: ACChildControllerInterface?

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

        acDestinationVC = ACDestinationWireframe().viewController
        acDeliveryDateVC = ACDeliveryDateWireframe().viewController

        updateUI(for: .deliveryDate)
    }

    private func generateAirBarTopMenu() -> UIView {
        UIView().then { view in

            sortSegmentedView = MainSegmentedView(
                items: ArbsVACSortType.allCases,
                selectedItem: viewModel.selectedSortType
            ).then { segmentedView in

                segmentedView.onSelect { [unowned self] item in
                    updateUI(for: item)
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
        airBarBottomContentView = UIView()
        return airBarBottomContentView
    }

    private func updateUI(for type: ArbsVACSortType) {
        activeController?.remove()

        switch type {
        case .deliveryDate:
            guard let controller = acDeliveryDateVC else { return }

            add(controller, to: view)
            activeController = controller

            airBarBottomContentView.removeAllSubviews()
            airBarBottomContentView.addSubview(controller.bottomAirBarContentView) {
                $0.edges.equalToSuperview()
            }

        case .destination:
            guard let controller = acDestinationVC else { return }

            add(controller, to: view)
            activeController = controller

            airBarBottomContentView.removeAllSubviews()
            airBarBottomContentView.addSubview(controller.bottomAirBarContentView) {
                $0.edges.equalToSuperview()
            }
        }
    }

    private func generateAirBarBottomDeliveryDateView(in view: UIView) {
        
    }


}

extension ArbsComparationViewController: ACWebTradeViewDelegate {

    func acWebTradeViewControllerDidChangeContentOffset(_ viewController: ACWebTradeViewController, offset: CGFloat, direction: MovingDirection) {
        actionsDelegate?.arbsComparationViewControllerDidChangeContentOffset(
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

extension ArbsComparationViewController: ArbsComparationViewModelDelegate {
}
