//
//  MainTabsViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import UIKit
import SpartaHelpers

class MainTabsViewController: BaseViewController {

    // MARK: - Public properties

    var selectedTabIndex: Int = 0 {
        didSet { updateActiveTab() }
    }

    // MARK: - Private properties

    private let viewModel = MainTabsViewModel()

    private var contentView: UIView!
    private var tabMenuView: TabMenuView!

    private let floatyMenuManager: FloatyMenuManager

    // MARK: - Initializers

    init() {
        self.floatyMenuManager = FloatyMenuManager()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        navigationBar(hide: true)
    }

    // MARK: - Private methods

    private func setupUI() {
        view.backgroundColor = .mainBackground

        let bottomView = UIView().then { view in

            view.backgroundColor = .neutral85

            func viewHeight() -> CGFloat {
                guard UIApplication.isDeviceWithSafeArea else { return 0 }

                return UIApplication.safeAreaInsets.bottom * 0.7
            }

            addSubview(view) {
                $0.left.bottom.right.equalToSuperview()
                $0.height.equalTo(viewHeight())
            }
        }

        contentView = UIView().then { view in

            view.backgroundColor = .mainBackground
        }

        tabMenuView = TabMenuView().then { view in

            view.delegate = self
            view.apply(items: generateMenuItems(), selectedTabIndex: selectedTabIndex)

            view.snp.makeConstraints {
                $0.height.equalTo(65)
            }
        }

        _ = UIStackView().then { stackView in

            stackView.axis = .vertical
            stackView.distribution = .fill
            stackView.alignment = .fill

            stackView.addArrangedSubview(contentView)
            stackView.addArrangedSubview(tabMenuView)

            addSubview(stackView) {
                $0.left.right.top.equalToSuperview()
                $0.bottom.equalTo(bottomView.snp.top)
            }
        }
    }

    private func updateActiveTab() {
        tabMenuView.selectedTabIndex = selectedTabIndex
    }

    private func generateMenuItems() -> [TabMenuItem] {
        var tabs: [TabMenuItem] = []

        if viewModel.isVisibleLivePricesBlock {
            let first = LiveCurvesViewController()
            first.coordinatorDelegate = self

            let navigation = KeyedNavigationController<Tab>(rootViewController: first)
            navigation.setKey(.liveCurves)

            tabs.append(.init(title: "MainTabsPage.LiveCurves.Title".localized,
                              imageName: "ic_tab_second",
                              controller: navigation))
        }

        // live charts navigation

        if viewModel.isVisibleLiveChartsBlock {
            let lcViewController = LCWebWireframe().viewController

            let lcNavigation = KeyedNavigationController<Tab>(rootViewController: lcViewController)
            lcNavigation.setKey(.liveCharts)

            tabs.append(.init(title: "MainTabsPage.LiveCharts.Title".localized,
                              imageName: "ic_tab_lc",
                              controller: lcNavigation))
        }

        // arbs navigation

        if viewModel.isVisibleArbsBlock {
//            let vc = ArbsContentViewController()
            let vc = ArbsViewController()
            vc.mainTabsViewController = self

            let navigation = KeyedNavigationController<Tab>(rootViewController: vc)
            navigation.setKey(.arbs)

            tabs.append(.init(title: "MainTabsPage.ARBs.Title".localized,
                              imageName: "ic_tab_first",
                              controller: navigation))
        }

        if !viewModel.isVisibleLiveChartsBlock && viewModel.isVisibleBlenderBlock {
            let third = BlenderViewController()

            let navigation = KeyedNavigationController<Tab>(rootViewController: third)
            navigation.setKey(.blender)

            tabs.append(.init(title: "MainTabsPage.Blender.Title".localized,
                              imageName: "ic_tab_third",
                              controller: navigation))
        }

        if !viewModel.isVisibleLiveChartsBlock && viewModel.isVisibleFreightBlock {
            let fourth = FreightViewController()

            let navigation = KeyedNavigationController<Tab>(rootViewController: fourth)
            navigation.setKey(.freight)

            tabs.append(.init(title: "MainTabsPage.Freight.Title".localized,
                              imageName: "ic_tab_fourth",
                              controller: navigation))
        }

        if !viewModel.isVisibleLiveChartsBlock {
            // settings
            let fifth = SettingsViewController()

            let navigation = KeyedNavigationController<Tab>(rootViewController: fifth)
            navigation.setKey(.settings)

            tabs.append(.init(title: "MainTabsPage.Settings.Title".localized,
                              imageName: "ic_tab_fifth",
                              controller: navigation))
        }

        // other navigation

        if viewModel.isVisibleLiveChartsBlock {
            let otherViewController = LCWebWireframe().viewController

            let otherNavigation = KeyedNavigationController<Tab>(rootViewController: otherViewController)
            otherNavigation.setKey(.other)

            tabs.append(.init(title: "MainTabsPage.Other.Title".localized,
                              imageName: "ic_tab_dots",
                              controller: otherNavigation))
        }

        return tabs
    }

    func generateOtherMenuItems() -> [TabMenuItem] {
        var tabs: [TabMenuItem] = []

        if viewModel.isVisibleBlenderBlock {
            let third = BlenderViewController()

            let navigation = KeyedNavigationController<Tab>(rootViewController: third)
            navigation.setKey(.blender)

            tabs.append(.init(title: "MainTabsPage.Blender.Title".localized,
                              imageName: "ic_tab_third",
                              controller: navigation))
        }

        if viewModel.isVisibleFreightBlock {
            let fourth = FreightViewController()

            let navigation = KeyedNavigationController<Tab>(rootViewController: fourth)
            navigation.setKey(.freight)

            tabs.append(.init(title: "MainTabsPage.Freight.Title".localized,
                              imageName: "ic_tab_fourth",
                              controller: navigation))
        }

        let fifth = SettingsViewController()

        let navigation = KeyedNavigationController<Tab>(rootViewController: fifth)
        navigation.setKey(.settings)

        tabs.append(.init(title: "MainTabsPage.Settings.Title".localized,
                          imageName: "ic_tab_fifth",
                          controller: navigation))

        return tabs
    }

    func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        tabMenuView.isHidden = hidden
    }
}

extension MainTabsViewController: TabMenuViewDelegate {

    func notifyAnalytics(oldTabItem: TabMenuItem, newTabItem: TabMenuItem) {
        if let oldNavigation = oldTabItem.controller as? KeyedNavigationController<Tab>,
           let selectedNavigation = newTabItem.controller as? KeyedNavigationController<Tab>,
           oldNavigation != selectedNavigation {

            viewModel.sendAnalyticsEventMenuClicked(from: oldNavigation.key?.analyticsName ?? "",
                                                    to: selectedNavigation.key?.analyticsName ?? "")
        }
    }

    func tabMenuViewDidSelectTab(_ view: TabMenuView, oldTabItem: TabMenuItem, newTabItem: TabMenuItem) {
        guard let navigationVC = newTabItem.controller as? KeyedNavigationController<Tab> else { return }

        if navigationVC.key == .other {
            floatyMenuManager.show(
                frame: contentView.frame,
                menuItemsCount: view.items.count,
                tabs: generateOtherMenuItems()
            )

            floatyMenuManager.onChoose { [unowned self] menuItem in
                floatyMenuManager.hide()
                tabMenuViewDidSelectTab(view, oldTabItem: oldTabItem, newTabItem: menuItem)

                notifyAnalytics(oldTabItem: oldTabItem, newTabItem: menuItem)
            }

            floatyMenuManager.onHide { [unowned self] in
                tabMenuView.forceChangeItem(oldTabItem)
            }

            return
        }

        if navigationVC.key == .liveCharts {
            InterfaceOrientationUtility.lockOrientation(.all, rotateTo: .portrait)
        } else {
            InterfaceOrientationUtility.lockOrientation(.portrait, rotateTo: .portrait)
        }

        floatyMenuManager.hide()
        contentView.removeAllSubviews()

        add(newTabItem.controller, to: contentView)
        notifyAnalytics(oldTabItem: oldTabItem, newTabItem: newTabItem)
    }

    func tabMenuViewDidDoubleTapOnTab(_ view: TabMenuView, tabItem: TabMenuItem) {
        guard let navigationVC = tabItem.controller as? KeyedNavigationController<Tab> else { return }

        navigationVC.popToRootViewController(animated: true)
    }
}

extension MainTabsViewController {

    fileprivate enum Tab: Hashable {
        case arbs
        case liveCharts
        case liveCurves
        case blender
        case freight
        case settings
        case other

        var analyticsName: String {
            switch self {
            case .arbs:
                return "arbs"

            case .liveCharts:
                return "live charts"

            case .liveCurves:
                return "live curves"

            case .blender:
                return "blender"

            case .freight:
                return "freight"

            case .settings:
                return "settings"

            case .other:
                return "other"
            }
        }
    }
}

extension MainTabsViewController: LiveCurvesViewCoordinatorDelegate {

    func liveCurvesViewControllerDidSelectMonthInfo(_ viewController: LiveCurvesViewController, monthInfo: LiveCurveMonthInfoModel) {
        guard let navigationVC = tabMenuView.items[1].controller as? KeyedNavigationController<Tab>, navigationVC.key == .liveCharts else { return }

        guard let lcViewController = navigationVC.viewControllers.first as? LCWebViewController else { return }

        guard LCWebRestriction.validItemsCodes.contains(monthInfo.lcCode),
                LCWebRestriction.validDateSelectors.contains(monthInfo.monthDisplayName) else { return }

        let item = LCWebViewModel.Item(monthInfo: monthInfo)
        var configurator = LCWebViewModel.Configurator(item: item)
        configurator.dateSelector = LCWebViewModel.DateSelector(name: monthInfo.monthDisplayName,
                                                                code: monthInfo.monthDisplayName)

        selectedTabIndex = 1

        onMainThread(delay: 0.3) {
            lcViewController.viewModel.apply(configurator: configurator)
        }
    }
}
