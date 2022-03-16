//
//  LCWebViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 03.02.2022.
//

import UIKit
import SpartaHelpers
import PanModal
import NetworkingModels

class LCWebViewController: BaseViewController {

    // MARK: - Public methods

    private(set) var viewModel: LCWebViewModelInterface!

    // MARK: - Private properties

    private var scrollView: UIScrollView!
    private var itemsField: UITextFieldSelector<PickerIdValued<String>>!
    private var selectorsField: UITextFieldSelector<PickerIdValued<String>>!
    private var historicalView: LCWebHistoricalDataView!
    private var mainChartController: LCWebTradeViewController!
    private var loaderView: LoaderView?

    private var fullScreenChartManager = FullScreenChartViewManager() 

    // MARK: - Initializers

    init(viewModel: LCWebViewModelInterface) {
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
        viewModel.loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.startLive()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        viewModel.stopLive()
    }

    // MARK: - Private methods

    private func setupUI() {

        setupNavigationUI()
        view.backgroundColor = .mainBackground

        scrollView = UIScrollView().then { scrollView in

            scrollView.showsVerticalScrollIndicator = false
            scrollView.backgroundColor = .neutral75

            let refreshTitleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.primaryText,
                                          NSAttributedString.Key.font: UIFont.main(weight: .regular, size: 12)]

            let refreshControl = UIRefreshControl(frame: .zero)
            refreshControl.tintColor = UIColor.primaryText
            refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            refreshControl.attributedTitle = NSAttributedString(
                string: "LiveCharts.RefreshControl.Title".localized,
                attributes: refreshTitleAttributes
            )
            refreshControl.addTarget(self, action: #selector(onPullToRefreshEvent(_:)), for: .valueChanged)

            scrollView.refreshControl = refreshControl

            addSubview(scrollView) {
                $0.top.equalToSuperview().offset(topBarHeight)
                $0.left.bottom.right.equalToSuperview()
            }
        }

        let scrollViewContent = UIView().then { view in

            view.backgroundColor = .clear

            scrollView.addSubview(view) {
                $0.left.top.right.equalToSuperview()
                $0.bottom.lessThanOrEqualToSuperview().priority(.high)
                $0.centerX.equalToSuperview()
            }
        }

        let itemsFieldConfigurator = UITextFieldSelectorConfigurator(
            leftSpace: 10,
            imageRightSpace: 11,
            imageLeftSpace: 3,
            cornerRadius: 10,
            defaultTextAttributes: [NSAttributedString.Key.foregroundColor: UIColor.primaryText,
                                    NSAttributedString.Key.font: UIFont.main(weight: .regular, size: 18)]
        )

        itemsField = UITextFieldSelector(configurator: itemsFieldConfigurator).then { view in

            view.backgroundColor = .neutral85
            view.onTap { [unowned self] in
                let wireframe = LCItemsSelectorWireframe(groups: viewModel.groups, coordinatorDelegate: self)
                navigationController?.pushViewController(wireframe.viewController, animated: true)
            }
        }

        let selectorsFieldConfigurator = UITextFieldSelectorConfigurator(
            leftSpace: 10,
            imageRightSpace: 11,
            imageLeftSpace: 3,
            image: UIImage(systemName: "calendar", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)),
            imageSize: CGSize(width: 20, height: 18),
            cornerRadius: 10,
            defaultTextAttributes: [NSAttributedString.Key.foregroundColor: UIColor.primaryText,
                                    NSAttributedString.Key.font: UIFont.main(weight: .regular, size: 18)]
        )

        selectorsField = UITextFieldSelector(configurator: selectorsFieldConfigurator).then { view in

            view.backgroundColor = .neutral85
            view.onTap { [unowned self] in
                guard let configurator = viewModel.configurator else { return }

                let wireframe = LCDatesSelectorWireframe(
                    dateSelectors: configurator.dateSelectors,
                    selectedDateSelector: configurator.selectedDateSelector,
                    coordinatorDelegate: self)

                presentPanModal(wireframe.viewController)
            }
        }

        let selectorsStackView = UIStackView().then { stackView in

            stackView.alignment = .fill
            stackView.axis = .horizontal
            stackView.spacing = 13
            stackView.distribution = .fillEqually

            stackView.addArrangedSubview(itemsField)
            stackView.addArrangedSubview(selectorsField)

            scrollViewContent.addSubview(stackView) {
                $0.top.equalToSuperview().offset(8)
                $0.left.right.equalToSuperview().inset(16)
                $0.height.equalTo(32)
            }
        }

        let tradeViewContent = UIView().then { view in

            mainChartController = LCWebTradeViewController(edges: .zero)
            mainChartController.delegate = self

            add(mainChartController, to: view)

            _ = TappableButton().then { button in

                button.backgroundColor = .neutral80
                button.setImage(UIImage(named: "ic_chart_expand"), for: .normal)
                button.onTap { [unowned self] _ in
                    guard let item = viewModel.configurator?.item else { return }

                    fullScreenChartManager.show(
                        productCode: item.code,
                        dateCode: viewModel.configurator?.dateSelector?.code,
                        orientation: .landscapeRight
                    )
                }

                view.addSubview(button) {
                    $0.size.equalTo(32)
                    $0.bottom.equalToSuperview().inset(44)
                    $0.right.equalToSuperview().inset(6)
                }
            }

            scrollViewContent.addSubview(view) {
                $0.top.equalTo(selectorsStackView.snp.bottom).offset(8)
                $0.left.right.equalToSuperview()
                $0.height.equalTo(460)
            }
        }

        historicalView = LCWebHistoricalDataView().then { view in

            scrollViewContent.addSubview(view) {
                $0.left.right.equalToSuperview()
                $0.top.equalTo(tradeViewContent.snp.bottom).offset(1)
                $0.bottom.equalToSuperview()
            }
        }

        loaderView = LoaderView().then { view in

            view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

            scrollViewContent.addSubview(view) {
                $0.top.equalTo(selectorsStackView.snp.bottom).offset(8)
                $0.left.right.bottom.equalToSuperview()
            }
        }
    }

    private func setupNavigationUI() {
        navigationItem.title = nil

        let title = "MainTabsPage.LiveCharts.Title".localized
        navigationItem.leftBarButtonItem = UIBarButtonItemFactory.logoButton(title: title)
    }

    // MARK: - Events

    @objc
    private func onPullToRefreshEvent(_ refreshControl: UIRefreshControl) {
        guard let configurator = viewModel.configurator else {
            refreshControl.endRefreshing()
            return
        }

        mainChartController.load(configurator: .init(
            productCode: configurator.item.code,
            dateCode: configurator.dateSelector?.code,
            isPortraitMode: true
        )
        )

        onMainThread(delay: 1) {
            refreshControl.endRefreshing()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard let orientation = UIApplication.interfaceOrientation,
              orientation.isLandscape,
              let configurator = viewModel.configurator,
              !fullScreenChartManager.isPresented else { return }

        fullScreenChartManager.show(
            productCode: configurator.item.code,
            dateCode: configurator.dateSelector?.code,
            orientation: orientation
        )
    }
}

extension LCWebViewController: LCWebTradeViewDelegate {

    func lcWebTradeViewControllerDidChangeContentOffset(_ viewController: LCWebTradeViewController, offset: CGFloat, direction: MovingDirection) {
        var currentOffset = scrollView.contentOffset.y

        if direction == .up {
            currentOffset -= offset
        } else {
            currentOffset += offset
        }

        scrollView.contentOffset = CGPoint(x: 0, y: currentOffset)
    }

    func lcWebTradeViewControllerDidTapOnHLView(_ viewController: LCWebTradeViewController) {
        scrollView.scrollView_scrollToBottom(animated: true)
    }

    func lcWebTradeViewControllerDidChangeOrientation(_ viewController: LCWebTradeViewController, interfaceOrientation: UIInterfaceOrientation) {
    }
}

extension LCWebViewController: LCItemsSelectorViewCoordinatorDelegate {

    func lcItemsSelectorViewControllerDidChooseItem(_ viewController: LCItemsSelectorViewController, item: LCWebViewModel.Item) {
        viewModel.apply(configurator: LCWebViewModel.Configurator(item: item))
    }
}

extension LCWebViewController: LCDatesSelectorViewCoordinatorDelegate {

    func lcDatesSelectorViewDidChooseDate(_ viewController: LCDatesSelectorViewController, dateSelector: LiveChartDateSelector) {
        viewModel.setDate(.init(dateSelector: dateSelector))
    }
}

extension LCWebViewController: LCWebViewModelDelegate {

    func didChangeLoadingState(_ isLoading: Bool) {
        if isLoading {
            loaderView?.isHidden = false
            loaderView?.startAnimating()
        } else {
            loaderView?.isHidden = true
            loaderView?.stopAnimating()
        }
    }

    func didCatchAnError(_ error: String) {
    }

    func didSuccessUpdateConfigurator(_ configurator: LCWebViewModel.Configurator) {
        let item = configurator.item

        itemsField.apply(selectedValue: .init(id: item.code, title: item.title, fullTitle: item.title), placeholder: "Select item")

        if let dateSelector = configurator.dateSelector {
            let name = dateSelector.name
            selectorsField.apply(selectedValue: .init(id: name, title: name, fullTitle: name), placeholder: "Select date")
        }

        if !configurator.highlights.isEmpty {
            historicalView.setupUI(highlights: configurator.highlights)
        } else {
            historicalView.clear()
        }
    }

    func didSuccessUpdateDateSelector(_ dateSelector: LCWebViewModel.DateSelector) {
        guard let configurator = viewModel.configurator else { return }

        mainChartController.load(configurator: .init(
            productCode: configurator.item.code,
            dateCode: configurator.dateSelector?.code,
            isPortraitMode: true
        ))
    }

    func didSuccessUpdateHighlights(_ highlights: [LCWebViewModel.Highlight]) {
        historicalView.setupUI(highlights: highlights)
    }
}
