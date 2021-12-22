//
//  ArbsVContentViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 24.11.2021.
//

import UIKit

class ArbsVContentViewController: UIViewController, ArbsVContentControllerInterface {

    func addObserver(_ observer: ArbsVContentControllerObserver) {
    }

    func removeObserver(_ observer: ArbsVContentControllerObserver) {
    }


    // MARK: - Private Properties

    fileprivate var contentScrollView: UIScrollView!
    var airBar: ArbVHeaderView!
    var configurator: Configurator!
//    fileprivate var backgroundView: UIView!
    fileprivate var darkMenuView: UIView!
    fileprivate var lightMenuView: UIView!
    fileprivate var normalView: UIView!
    fileprivate var expandedView: UIView!
    fileprivate var backButton: UIButton!
    fileprivate var barController: BarController!

    fileprivate var shouldHideStatusBar = false {
        didSet {
            guard shouldHideStatusBar != oldValue else { return }
            updateStatusBar()
        }
    }

    fileprivate var prefersStatusBarStyle = UIStatusBarStyle.lightContent {
        didSet {
            guard prefersStatusBarStyle != oldValue else { return }
            updateStatusBar()
        }
    }

    private enum Constants {
        static let normalStateHeight: CGFloat = 100
        static let compactStateHeight: CGFloat = 60
        static let expandedStateHeight: CGFloat = 100
    }

    fileprivate var numberOfItems = 10
    fileprivate var secondTableViewShown: Bool?

    // MARK: - Initializers

//    init(pricingCenter)

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .neutral75

        let sideView = UIView().then { view in

            view.backgroundColor = .yellow

            addSubview(view) {
                $0.top.bottom.equalToSuperview()
                $0.left.equalTo(view.safeAreaLayoutGuide.snp.right)
                $0.right.equalToSuperview()
            }
        }

        contentScrollView = UIScrollView().then { scrollView in

            scrollView.showsVerticalScrollIndicator = false
//            scrollView.delegate

            view.addSubview(scrollView) {
                $0.top.bottom.equalToSuperview()
                $0.right.equalTo(view.safeAreaLayoutGuide.snp.right)
                $0.left.equalTo(view.safeAreaLayoutGuide.snp.left)
            }
//            addSubview(scrollView) {
//                $0.top.equalToSuperview().offset(topBarHeight + 12)
//                $0.left.bottom.right.equalToSuperview()
//            }
        }

        let scrollViewContent = UIView().then { view in

            view.backgroundColor = .red

            contentScrollView.addSubview(view) {
                $0.height.equalTo(1000)
                $0.edges.equalToSuperview()
                $0.centerX.equalToSuperview()
            }
        }

        let testView = UIView().then { view in

            view.backgroundColor = .white

            scrollViewContent.addSubview(view) {
                $0.size.equalTo(100)
                $0.left.top.equalToSuperview()
            }
        }

//        backgroundView = UIImageView(image: #imageLiteral(resourceName: "grad"))
//        backgroundView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: Constants.normalStateHeight)

//        darkMenuView = UIView()
//        darkMenuView.backgroundColor = .red
//        darkMenuView.frame = CGRect(x: 0, y: Constants.normalStateHeight - 80, width: view.frame.width, height: view.frame.height)
////        darkMenuView.setStyle(light: false)
//
//        lightMenuView = UIView()
//        lightMenuView.frame = darkMenuView.frame
//        lightMenuView.backgroundColor = .yellow
////        lightMenuView.setStyle(light: true)
//
//        normalView = UIView(frame: .init(x: 0, y: 0, width: view.frame.width, height: 100))
//        normalView.clipsToBounds = true
//        normalView.backgroundColor = .orange
////        normalView.searchTapGestureRecognizer.addTarget(self, action: #selector(handleSearchViewTapped(_:)))
////
//        expandedView = UIView(frame: .init(x: 0, y: 0, width: view.frame.width, height: 100))
//        expandedView.backgroundColor = .black
//        expandedView.clipsToBounds = true
//
////        backButton = UIButton(frame: CGRect(x: 22, y: 34, width: 40, height: 40))
////        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
////        backButton.imageEdgeInsets = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)
////        backButton.addTarget(self, action: #selector(self.handleBackButtonPressed(_:)), for: .touchUpInside)
//


        airBar = ArbVHeaderView().then { view in

//            view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
            self.view.addSubview(view) {
                $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
                $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
                $0.height.equalTo(100)
            }
        }



//
////        airBar.addSubview(backgroundView)
//        airBar.addSubview(darkMenuView)
//        airBar.addSubview(lightMenuView)
//        airBar.addSubview(normalView)
//        airBar.addSubview(expandedView)
////        airBar.addSubview(backButton)
//        view.addSubview(airBar)

        let configuration = Configuration(
            compactStateHeight: Constants.compactStateHeight,
            normalStateHeight: Constants.normalStateHeight,
            expandedStateHeight: Constants.expandedStateHeight
        )

        let barStateObserver: (Sparta.State) -> Void = { [weak self] state in
            self?.handleBarControllerStateChanged(state: state)
        }

        barController = Sparta.BarController(configuration: configuration, stateObserver: barStateObserver)

        toggleSecondTable(on: false)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
//            self.airBar.frame = CGRect(x: self.airBar.frame.minX, y: self.airBar.frame.minY, width: size.width, height: self.airBar.frame.height)
//            self.backgroundView.frame = CGRect(x: self.backgroundView.frame.minX, y: self.backgroundView.frame.minY, width: size.width, height: self.backgroundView.frame.height)
//            self.normalView.frame = CGRect(x: self.normalView.frame.minX, y: self.normalView.frame.minY, width: size.width, height: self.normalView.frame.height)
//            self.expandedView.frame = CGRect(x: self.expandedView.frame.minX, y: self.expandedView.frame.minY, width: size.width, height: self.expandedView.frame.height)
        }, completion: nil)
    }

    // MARK: - Status Bar

    override var prefersStatusBarHidden: Bool {
        return shouldHideStatusBar
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return prefersStatusBarStyle
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }

    private func updateStatusBar() {
        UIView.animate(withDuration: 0.20, delay: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }

    // MARK: - Table Views
    private func toggleSecondTable(on: Bool) {
        let animated = self.secondTableViewShown != nil
        self.secondTableViewShown = on

        let leftHiddenFrame = CGRect(x: -view.frame.width, y: 0, width: view.frame.width, height: view.frame.height)
        let rightHiddenFrame = CGRect(x: view.frame.width, y: 0, width: view.frame.width, height: view.frame.height)
        let shownFrame = view.bounds

        let animate = {
            self.contentScrollView.frame = on ? leftHiddenFrame : shownFrame
//            self.firstTableView.frame = on ? leftHiddenFrame : shownFrame
//            self.secondTableView.frame = on ? shownFrame : rightHiddenFrame
        }

        let completion = {
            self.barController.set(scrollView: self.contentScrollView)
        }

        self.barController.preconfigure(scrollView: contentScrollView)

        guard animated else {
            animate()
            completion()
            return
        }

        UIView.animate(withDuration: 0.3, animations: animate, completion: { _ in completion() })
    }

    // MARK: - User Interaction

    @objc private func handleBackButtonPressed(_ button: UIButton) {
        barController.expand(on: false)
    }

    @objc private func handleSearchViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        barController.expand(on: true)
    }

    @IBAction func handleReloadButtonPressed(_ sender: UIButton) {
//        numberOfItems = 1 + Int(arc4random_uniform(20))
//        firstTableView.reloadData()
//        secondTableView.reloadData()
    }

    @IBAction func handleChangeButtonPressed(_ sender: UIButton) {
        guard let secondTableViewShown = secondTableViewShown else { return }
        toggleSecondTable(on: !secondTableViewShown)
    }

    // MARK: - BarController Handler
    private func handleBarControllerStateChanged(state: Sparta.State) {
        let height = state.height()
        let transitionProgress = state.transitionProgress()

        print("SCROLL offset *: \(state.offset)")

        shouldHideStatusBar = transitionProgress > 0 && transitionProgress < 1
        prefersStatusBarStyle = transitionProgress > 0.5 ? .lightContent : .default

//        airBar.frame = CGRect(
//            x: airBar.frame.origin.x,
//            y: airBar.frame.origin.y,
//            width: airBar.frame.width,
//            height: height // <~ Animated property
//        )

        airBar.snp.updateConstraints {
            $0.height.equalTo(height)
        }

        airBar.applyState(isMinimized: transitionProgress < 1)

//        backgroundView.frame = CGRect(
//            x: backgroundView.frame.origin.x,
//            y: backgroundView.frame.origin.y,
//            width: backgroundView.frame.width,
//            height: height // <~ Animated property
//        )

//        backgroundView.alpha = state.value(compactNormalRange: .range(0, 1), normalExpandedRange: .value(1)) // <~ Animated property

//        normalView.frame = CGRect(
//            x: normalView.frame.origin.x,
//            y: state.value(compactNormalRange: .range(-24, 40), normalExpandedRange: .range(40, 80)), // <~ Animated property
//            width: normalView.frame.width,
//            height: normalView.frame.height
//        )
//
//        normalView.alpha = state.value(compactNormalRange: .range(0, 1), normalExpandedRange: .range(1, 0)) // <~ Animated property
//
//        expandedView.frame = CGRect(
//            x: expandedView.frame.origin.x,
//            y: state.value(compactNormalRange: .value(40), normalExpandedRange: .range(40, 80)),
//            width: expandedView.frame.width,
//            height: state.value(compactNormalRange: .value(44), normalExpandedRange: .range(44, 164))
//        )
//
//        expandedView.alpha = state.value(compactNormalRange: .value(0), normalExpandedRange: .range(0, 1)) // <~ Animated property

//        backButton.alpha = state.value(compactNormalRange: .value(0), normalExpandedRange: .range(-1, 1)) // <~ Animated property

        /*lightMenuView.alpha = state.value(compactNormalRange: .range(0, 1), normalExpandedRange: .value(1)) // <~ Animated property

        darkMenuView.alpha = state.value(compactNormalRange: .range(1, 0), normalExpandedRange: .value(0)) // <~ Animated property

        lightMenuView.frame = CGRect(
            x: lightMenuView.frame.origin.x,
            y: height - 40, // <~ Animated property
            width: lightMenuView.frame.width,
            height: lightMenuView.frame.height
        )

        darkMenuView.frame = lightMenuView.frame*/
    }
}
