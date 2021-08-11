//
//  ArbsPlaygroundViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 23.07.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers

class ArbsPlaygroundViewController: BaseVMViewController<ArbsPlaygroundViewModel> {

    // MARK: - Private properties

    private var searchController: UISearchController!
    private var searchWireframe: ArbSearchWireframe!
    private var monthSelector: ResultMonthSelector!
    private var contentScrollView: UIScrollView!

    private var inputDataView: ArbPlaygroundInputDataView!
    private var resultDataView: ArbPlaygroundResultDataView!

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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // view model

        viewModel.loadData()
    }

    //
    // MARK: Keyboard Management

    var addedSize: CGSize = .zero

    override func updateUIForKeyboardPresented(_ presented: Bool, frame: CGRect) {
        super.updateUIForKeyboardPresented(presented, frame: frame)

        if presented && addedSize == .zero {
            var oldContentSize = contentScrollView.contentSize
            oldContentSize.height += frame.size.height

            addedSize.height = frame.size.height

            contentScrollView.contentSize = oldContentSize
        } else if !presented && addedSize != .zero {
            var oldContentSize = contentScrollView.contentSize
            oldContentSize.height -= addedSize.height
            addedSize = .zero

            contentScrollView.contentSize = oldContentSize
        }

        if let selectedTextField = view.selectedField {
            let newFrame = selectedTextField.convert(selectedTextField.frame, to: view)
            let maxFieldFrame = newFrame.maxY + 100

            if maxFieldFrame > frame.minY {
                contentScrollView.contentOffset = CGPoint(x: 0, y: maxFieldFrame - frame.minY)
            }
        }
    }

    // MARK: - Private methods

    private func setupUI() {
        // top month selector

        monthSelector = ResultMonthSelector().then { view in

            view.delegate = self

            addSubview(view) {
                $0.top.equalTo(self.view.snp_topMargin).offset(12)
                $0.left.right.equalToSuperview().inset(16)
                $0.height.equalTo(39)
            }
        }

        reloadMonthsData()

        ///

        contentScrollView = UIScrollView().then { scrollView in

            scrollView.showsVerticalScrollIndicator = false
            scrollView.isHidden = true

            addSubview(scrollView) {
                $0.top.equalTo(monthSelector.snp.bottom).offset(8)
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

        inputDataView = ArbPlaygroundInputDataView().then { view in

            view.delegate = self

            scrollViewContent.addSubview(view) {
                $0.left.equalToSuperview().offset(16)
                $0.right.equalToSuperview().inset(22)
                $0.top.equalToSuperview()
            }
        }

        // result block

        let resultView = UIView().then { view in

            view.backgroundColor = .plResultBlockBackground
            view.layer.cornerRadius = 10

            scrollViewContent.addSubview(view) {
                $0.top.equalTo(inputDataView.snp.bottom)
                $0.left.right.equalToSuperview().inset(16)
                $0.bottom.equalToSuperview()
            }
        }

        resultDataView = ArbPlaygroundResultDataView().then { view in

            view.delegate = self

            resultView.addSubview(view) {
                $0.left.right.equalToSuperview().inset(12)
                $0.top.bottom.equalToSuperview()
            }
        }
    }

    private func setupNavigationUI() {
        navigationItem.title = "Playground"
        navigationBar(hide: false)
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: searchWireframe.viewController).then { vc in
            vc.setup(placeholder: "Search.Title".localized,
                     placeholderColor: ArbsPlaygroundUIConstants.searchPlaceholderColor,
                     searchResultsUpdater: searchWireframe.viewController)
            vc.delegate = searchWireframe.viewController
        }

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
}

extension ArbsPlaygroundViewController: RoundedTextFieldDelegate {
}

extension ArbsPlaygroundViewController: ArbSearchControllerCoordinatorDelegate {

    func arbSearchControllerDidChoose(arb: Arb) {
        searchController.isActive = false
        viewModel.changeArb(arb)
    }
}

extension ArbsPlaygroundViewController: ArbPlaygroundResultDataViewDelegate {

    func arbPlaygroundResultDataViewDidChangeTGTValue(_ view: ArbPlaygroundResultDataView, newValue: Double?) {
        viewModel.changeUserTgt(newValue)
    }
}

extension ArbsPlaygroundViewController: ArbPlaygroundInputDataViewDelegate {

    func arbPlaygroundInputDataViewDidChangeValue(_ view: ArbPlaygroundInputDataView, newValue: ArbPlaygroundInputDataView.ObjectValue) {
        switch newValue {
        case .blendCost(let value):
            viewModel.changeBlendCost(value)

        case .gasNap(let value):
            viewModel.changeBlendCost(value)

        case .taArb(let value):
            viewModel.changeTaArb(value)

        case .ew(let value):
            viewModel.changeEw(value)

        case .freight(let value):
            viewModel.changeFreight(value)

        case .costs(let value):
            viewModel.changeCosts(value)

        case .spreadMonth(let value):
            viewModel.changeDeliveredPriceSpreadsMonth(value)
        }
    }
}

extension ArbsPlaygroundViewController: ResultMonthSelectorDelegate {

    func resultMonthSelectorDidTapLeftButton(view: ResultMonthSelector) {
        viewModel.showPreviousMonth()
    }

    func resultMonthSelectorDidTapRightButton(view: ResultMonthSelector) {
        viewModel.showNextMonth()
    }
}

extension ArbsPlaygroundViewController: ArbsPlaygroundViewModelDelegate {

    func didChangeLoadingState(_ isLoading: Bool) {
        searchController.searchBar.isHidden = isLoading
        contentScrollView.isHidden = isLoading
        loadingView(isAnimating: isLoading)
    }

    func didCatchAnError(_ error: String) {
    }

    func didLoadArbs(_ arbs: [Arb]) {
        searchWireframe.apply(arbs: arbs)
    }

    func didReceiveMonthInfoUpdates() {
        reloadMonthsData()

        if let arb = viewModel.arb {
            searchController.setup(placeholder: arb.grade + " | " + arb.dischargePortName + " | " + arb.freightType)
        }
    }

    func didReceiveInputDataConstructor(_ constructor: ArbPlaygroundInputDataView.Constructor) {
        inputDataView.state = .active(constructor: constructor)
    }

    func didReceiveResultDataConstructors(_ constructors: [ArbPlaygroundResultViewConstructor]) {
        resultDataView.state = .active(constructors: constructors)
    }
}
