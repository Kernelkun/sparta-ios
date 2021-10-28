//
//  ArbsPlaygroundViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 23.07.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers

class ArbsPlaygroundViewController: BaseViewController {

    // MARK: - Private properties

    private let viewModel: ArbsPlaygroundViewModel

    private var searchController: UISearchController!
    private var searchWireframe: ArbSearchWireframe!
    private var monthSelector: ResultMonthSelector!
    private var contentPageVC: UISliderViewController<ArbsPlaygroundPageViewController>!

    // MARK: - Initializers

    init(viewModel: ArbsPlaygroundViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // search wireframe

        searchWireframe = ArbSearchWireframe(arbs: [],
                                             coordinatorDelegate: self)

        // UI

        setupUI()
        setupNavigationUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupSearchController()

        // view model
        viewModel.loadData()
    }

    //
    // MARK: Keyboard Management

    var addedSize: CGSize = .zero

    override func updateUIForKeyboardPresented(_ presented: Bool, frame: CGRect) {
        super.updateUIForKeyboardPresented(presented, frame: frame)

        let selectedVC = contentPageVC.selectedController
        if presented && addedSize == .zero {
            var oldContentSize = selectedVC.contentScrollView.contentSize
            oldContentSize.height += frame.size.height

            addedSize.height = frame.size.height

            selectedVC.contentScrollView.contentSize = oldContentSize
        } else if !presented && addedSize != .zero {
            var oldContentSize = selectedVC.contentScrollView.contentSize
            oldContentSize.height -= addedSize.height
            addedSize = .zero

            selectedVC.contentScrollView.contentSize = oldContentSize
        }

        if let selectedTextField = view.selectedField {
            let newFrame = selectedTextField.convert(selectedTextField.frame, to: view)
            let maxFieldFrame = newFrame.maxY + 100

            if maxFieldFrame > frame.minY {
                selectedVC.contentScrollView.contentOffset = CGPoint(x: 0, y: maxFieldFrame - frame.minY)
            }
        }
    }

    // MARK: - Private methods

    private func setupUI() {
        // top month selector

        monthSelector = ResultMonthSelector().then { view in

            view.isHidden = true
            view.delegate = self

            addSubview(view) {
                $0.top.equalTo(self.view.snp_topMargin).offset(8)
                $0.left.right.equalToSuperview().inset(16)
                $0.height.equalTo(31)
            }
        }

        reloadMonthsData()
        setupPageController()
    }

    private func setupPageController() {
        let contentView = UIView().then { view in

            addSubview(view) {
                $0.left.right.bottom.equalToSuperview()
                $0.top.equalTo(monthSelector.snp.bottom)
            }
        }

        /*let controllers = viewModel.arb.months.compactMap { _ -> ArbsPlaygroundPageViewController in
            let viewController = ArbsPlaygroundPageViewController()
            viewController.delegate = self
            return viewController
        }

        contentPageVC = UISliderViewController(controllers: controllers).then { sliderViewController in

            sliderViewController.coordinatorDelegate = self

            add(sliderViewController, to: contentView)
        }*/

        let historicalGraphItem = ArbPlaygroundMenuItemView(systemImageName: "point.filled.topleft.down.curvedto.point.bottomright.up",
                                                            title: "Historic\nGraph")

        let blndGraph = ArbPlaygroundMenuItemView(systemImageName: "chart.line.uptrend.xyaxis",
                                                            title: "Blnd\nGraph")

        let tableItem = ArbPlaygroundMenuItemView(systemImageName: "tablecells.fill.badge.ellipsis",
                                                            title: "Table")

        let menuView = ArbPlaygroundMenuView(items: [historicalGraphItem, blndGraph, tableItem]).then { view in

            contentView.addSubview(view) {
                $0.bottom.right.equalToSuperview().inset(24)
            }
        }

    }

    private func setupNavigationUI() {
        navigationItem.title = "ArbPlaygroundPage.PageTitle".localized
        navigationBar(hide: false)
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: searchWireframe.viewController).then { vc in
            vc.setup(placeholder: "Search.Title".localized,
                     placeholderColor: ArbsPlaygroundUIConstants.searchPlaceholderColor,
                     searchResultsUpdater: searchWireframe.viewController)
            vc.delegate = searchWireframe.viewController
        }

        searchController.searchBar.isHidden = true
        searchController.showsSearchResultsController = true
        navigationItem.searchController = searchController
        setupNavigationBarAppearance(backgroundColor: .barBackground)
    }

    private func setupNavigationBarAppearance(backgroundColor: UIColor? = nil) {

        let navigationBarAppearance = UINavigationBarAppearance().then {
            $0.configureWithOpaqueBackground()
            $0.backgroundColor = backgroundColor ?? .barBackground
            $0.titleTextAttributes = [.foregroundColor: UIColor.primaryText]
            $0.shadowColor = backgroundColor
        }

        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController?.navigationBar.compactAppearance = navigationBarAppearance
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance

        navigationController?.navigationBar.tintColor = .controlTintActive

        //

        let toolbarAppearance = UIToolbarAppearance().then {

            $0.configureWithOpaqueBackground()
            $0.backgroundColor = backgroundColor ?? .barBackground
        }

        navigationController?.toolbar.compactAppearance = toolbarAppearance
        navigationController?.toolbar.standardAppearance = toolbarAppearance
    }

    private func reloadMonthsData() {
        monthSelector.isEnabledLeftButton = viewModel.ableToSwitchPrevMonth
        monthSelector.isEnabledRightButton = viewModel.ableToSwitchNextMonth
        monthSelector.titleText = viewModel.formattedMonthTitle
    }

    override var preferredInterfaceOrientations: UIInterfaceOrientationMask {
        [.portrait, .landscapeLeft, .landscapeRight]
    }

    private var windowInterfaceOrientation: UIInterfaceOrientation? {
        return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            guard let windowInterfaceOrientation = InterfaceOrientationUtility.interfaceOrientation else { return }

            if windowInterfaceOrientation.isLandscape {
                // activate landscape changes
//                Alert.showOk(title: "Landscape", message: "Changed", show: self, completion: nil)
                self.navigationBar(hide: true)
            } else {
                // activate portrait changes
//                Alert.showOk(title: "Portrait", message: "Changed", show: self, completion: nil)

                self.navigationBar(hide: false)
            }
        })
    }
}

extension ArbsPlaygroundViewController: UISliderViewControllerDelegate {

    func uiSliderViewControllerDidShowController(at index: Int) {
        viewModel.switchToMonth(at: index)
    }
}

extension ArbsPlaygroundViewController: ArbSearchControllerCoordinatorDelegate {

    func arbSearchControllerDidChoose(arb: Arb) {
        searchController.isActive = false
        viewModel.changeArb(arb)
    }
}

extension ArbsPlaygroundViewController: ArbsPlaygroundPageViewControllerDelegate {

    func arbPlaygroundPageResultDataViewDidChangeTGTValue(_ view: ArbPlaygroundResultDataView, newValue: Double?) {
        viewModel.changeUserTgt(newValue)
    }

    func arbPlaygroundPageInputDataViewDidChangeValue(_ view: ArbPlaygroundInputDataView, newValue: ArbPlaygroundInputDataView.ObjectValue) {
        switch newValue {
        case .blendCost(let value, _):
            viewModel.changeBlendCost(value)

        case .gasNap(let value, let sign):
            viewModel.changeGasNap(value, sign: sign)

        case .taArb(let value, _):
            viewModel.changeTaArb(value)

        case .ew(let value, _):
            viewModel.changeEw(value)

        case .freight(let value, _):
            viewModel.changeFreight(value)

        case .costs(let value, _):
            viewModel.changeCosts(value)

        case .spreadMonth(let value):
            viewModel.changeDeliveredPriceSpreadsMonth(value)
        }
    }
}

extension ArbsPlaygroundViewController: ResultMonthSelectorDelegate {

    func resultMonthSelectorDidTapLeftButton(view: ResultMonthSelector) {
        contentPageVC.showPrevious()
    }

    func resultMonthSelectorDidTapRightButton(view: ResultMonthSelector) {
        contentPageVC.showNext()
    }
}

extension ArbsPlaygroundViewController: ArbsPlaygroundViewModelDelegate {

    func didChangeLoadingState(_ isLoading: Bool) {
        monthSelector.isHidden = isLoading
        loadingView(isAnimating: isLoading)
    }

    func didCatchAnError(_ error: String) {
    }

    func didLoadArbs(_ arbs: [Arb]) {
        searchController.searchBar.isHidden = false
        searchWireframe.apply(arbs: arbs)
    }

    func didReceiveMonthInfoUpdates() {
        reloadMonthsData()

        let arb = viewModel.arb
        searchController.setup(placeholder: arb.grade + " | " + arb.dischargePortName + " | " + arb.freightType)
    }

    func didReceiveInputDataConstructor(_ constructor: ArbPlaygroundInputDataView.Constructor) {
//        contentPageVC.selectedController.inputDataView.state = .active(constructor: constructor)
    }

    func didReceiveResultDataConstructors(_ constructors: [ArbPlaygroundResultViewConstructor]) {
//        contentPageVC.selectedController.resultDataView.state = .active(constructors: constructors)
    }
}
