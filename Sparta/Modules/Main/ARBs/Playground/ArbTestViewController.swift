//
//  ArbTestViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 26.10.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers
import Networking

class ArbTestViewController: BaseViewController {

    // MARK: - Private properties

    private var contentScrollView: UIScrollView!
    private var mainStackView: UIStackView!
    private var mainContentView: UIView!

    private var arbMenuContentView: UIView!
    private var arbMenu: ArbPlaygroundMenuView!

    private var arbVSyncManager = ArbsVSyncManager()

    // MARK: - Initializers

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        arbVSyncManager.start()
    }

    //
    // MARK: Keyboard Management

    /*var addedSize: CGSize = .zero

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
    }*/

    // MARK: - Private methods

    private func setupUI() {
        mainContentView = UIView().then { view in

            view.backgroundColor = .yellow
        }

        arbMenuContentView = prepareMenuView()

        mainStackView = UIStackView().then { stackView in

            stackView.axis = .horizontal
            stackView.distribution = .fill
            stackView.spacing = 0
            stackView.alignment = .fill

            stackView.addArrangedSubview(mainContentView)
            stackView.addArrangedSubview(arbMenuContentView)

            addSubview(stackView) {
                $0.right.equalTo(self.view.safeAreaLayoutGuide)
                $0.left.equalTo(self.view.safeAreaLayoutGuide)
                $0.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            }
        }

        prepareUI(for: InterfaceOrientationUtility.interfaceOrientation ?? .portrait)

        setupTestWireframe()
    }

    private func prepareMenuView() -> UIView {
        UIView().then { view in

            view.backgroundColor = .red

            let historicalGraphItem = ArbPlaygroundMenuItemView(systemImageName: "point.filled.topleft.down.curvedto.point.bottomright.up",
                                                                title: "Historic\nGraph")

            let blndGraph = ArbPlaygroundMenuItemView(systemImageName: "chart.line.uptrend.xyaxis",
                                                                title: "Blnd\nGraph")

            let tableItem = ArbPlaygroundMenuItemView(systemImageName: "tablecells.fill.badge.ellipsis",
                                                                title: "Table")

            _ = ArbPlaygroundMenuView(items: [historicalGraphItem, blndGraph, tableItem]).then { menuView in

                view.addSubview(menuView) {
                    $0.bottom.equalToSuperview().inset(21)
                    $0.right.equalToSuperview()
                    $0.left.equalToSuperview().offset(14)
                }
            }
        }
    }

    private func setupNavigationUI() {
        navigationItem.title = "ArbPlaygroundPage.PageTitle".localized
        navigationBar(hide: false)
    }

    private func prepareUI(for interface: UIInterfaceOrientation) {
        if interface.isPortrait {
            arbMenuContentView.isHidden = true
        } else if interface.isLandscape {
            arbMenuContentView.isHidden = false
        }
    }

    private func setupTestWireframe() {
        let wireframe = ArbsPlaygroundPCWireframe()
        add(wireframe.viewController, to: mainContentView)
    }

//    private func setupSearchController() {
//        searchController = UISearchController(searchResultsController: searchWireframe.viewController).then { vc in
//            vc.setup(placeholder: "Search.Title".localized,
//                     placeholderColor: ArbsPlaygroundUIConstants.searchPlaceholderColor,
//                     searchResultsUpdater: searchWireframe.viewController)
//            vc.delegate = searchWireframe.viewController
//        }
//
//        searchController.searchBar.isHidden = true
//        searchController.showsSearchResultsController = true
//        navigationItem.searchController = searchController
//        setupNavigationBarAppearance(backgroundColor: .barBackground)
//    }

//    private func setupNavigationBarAppearance(backgroundColor: UIColor? = nil) {
//
//        let navigationBarAppearance = UINavigationBarAppearance().then {
//            $0.configureWithOpaqueBackground()
//            $0.backgroundColor = backgroundColor ?? .barBackground
//            $0.titleTextAttributes = [.foregroundColor: UIColor.primaryText]
//            $0.shadowColor = backgroundColor
//        }
//
//        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
//        navigationController?.navigationBar.compactAppearance = navigationBarAppearance
//        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
//
//        navigationController?.navigationBar.tintColor = .controlTintActive
//
//        //
//
//        let toolbarAppearance = UIToolbarAppearance().then {
//
//            $0.configureWithOpaqueBackground()
//            $0.backgroundColor = backgroundColor ?? .barBackground
//        }
//
//        navigationController?.toolbar.compactAppearance = toolbarAppearance
//        navigationController?.toolbar.standardAppearance = toolbarAppearance
//    }

    override var preferredInterfaceOrientations: UIInterfaceOrientationMask {
        [.portrait, .landscapeLeft, .landscapeRight]
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            guard let interfaceOrientation = InterfaceOrientationUtility.interfaceOrientation else { return }

            self.prepareUI(for: interfaceOrientation)
        })
    }
}
