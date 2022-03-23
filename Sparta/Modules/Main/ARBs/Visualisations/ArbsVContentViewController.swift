//
//  ArbsVContentViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 24.11.2021.
//

import UIKit
import SpartaHelpers

class ArbsVContentViewController: UIViewController, ArbsVContentControllerInterface {

    // MARK: - Public Properties

    private(set) var currentPage: ArbsVContentPage!
    var airBar: ArbVHeaderView!
    var configurator: Configurator!

    var observers: WeakSet<ArbsVContentControllerObserver> = []

    // MARK: - Private properties

    private var scrollViewContent: UIView!
    private var contentScrollView: UIScrollView!
    private var barController: BarController!
    private var aVBarController: AVBarController!

    // MARK: - Initializers

    init() {
        currentPage = .pricingCenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .neutral75

        // side view
        _ = UIView().then { view in

            view.backgroundColor = .clear

            addSubview(view) {
                $0.top.bottom.equalToSuperview()
                $0.left.equalTo(view.safeAreaLayoutGuide.snp.right)
                $0.right.equalToSuperview()
            }
        }

        let arbHeaderConfigurator = ArbVHeaderView.Configurator(selectedIndexOfMenuItem: 0)

        airBar = ArbVHeaderView(configurator: arbHeaderConfigurator).then { barView in

            barView.delegate = self

            view.addSubview(barView) {
                $0.top.equalToSuperview()
                $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
                $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
                $0.height.equalTo(55)
            }
        }

        contentScrollView = UIScrollView().then { scrollView in

            scrollView.showsVerticalScrollIndicator = false

            view.addSubview(scrollView) {
                $0.top.equalToSuperview().offset(55)
                $0.bottom.equalToSuperview()
                $0.right.equalTo(view.safeAreaLayoutGuide.snp.right)
                $0.left.equalTo(view.safeAreaLayoutGuide.snp.left)
            }
        }

        scrollViewContent = UIView().then { view in

            view.backgroundColor = .clear

            contentScrollView.addSubview(view) {
                $0.edges.equalToSuperview()
                $0.centerX.equalToSuperview()
            }
        }

        let stateBarObserver: (AVBarController.State) -> Void = { [weak self] state in
            guard let strongSelf = self else { return }

            strongSelf.handleBarControllerStateChanged(state: state)
        }

        aVBarController = AVBarController(scrollabe: contentScrollView, stateBarObserver: stateBarObserver)
        presentContentPage(currentPage)
    }

    func presentContentPage(_ newPage: ArbsVContentPage) {
        switch newPage {
        case .pricingCenter:
            scrollViewContent.removeAllSubviews()
            add(configurator.pcChildController, to: scrollViewContent)

            let configurator = AVBarController.StatesConfigurator(
                expandPosition: .init(visibleRange: -1000 ... 0, height: 55),
                collapsedPosition: .init(visibleRange: 0 ... CGFloat.infinity, height: 55)
            )

            aVBarController.setStatesConfigurator(configurator)

        case .arbsComparation:
            scrollViewContent.removeAllSubviews()
            add(configurator.acChhildController, to: scrollViewContent)

            let configurator = AVBarController.StatesConfigurator(
                expandPosition: .init(visibleRange: -1000 ... 0, height: 100),
                collapsedPosition: .init(visibleRange: 0 ... CGFloat.infinity, height: 55)
            )

            aVBarController.setStatesConfigurator(configurator)
        }

        currentPage = newPage

        for observer in observers {
            observer.arbsVContentControllerDidChangePage(self, newPage: newPage)
        }
    }

    // MARK: - Public methods

    func addObserver(_ observer: ArbsVContentControllerObserver) {
        observers.insert(observer)
    }

    func removeObserver(_ observer: ArbsVContentControllerObserver) {
        observers.remove(observer)
    }

    // MARK: - AVBarController Handler

    private func handleBarControllerStateChanged(state: AVBarController.State) {
        print("isCollapsed: \(state.isCollapsed), height: \(state.position.height), contentOffset: \(state.contentOffset)")

        airBar.applyState(isMinimized: state.isCollapsed)
        airBar.snp.updateConstraints {
            $0.height.equalTo(state.position.height)
        }

        for observer in observers {
            observer.arbsVContentControllerDidChangeScrollState(self, newState: state, page: currentPage)
        }
    }
}

extension ArbsVContentViewController: ArbVHeaderViewDelegate {

    func arbVHeaderViewDidChangeSegmentedViewValue(_ view: ArbVHeaderView, item: MainSegmentedView.MenuItem) {
        switch item {
        case .pricingCenter:
            presentContentPage(.pricingCenter)

        case .arbsComparation:
            presentContentPage(.arbsComparation)
        }
    }
}
