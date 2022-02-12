//
//  LCWebViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 03.02.2022.
//

import UIKit
import SpartaHelpers

class LCWebViewController: UIViewController {

    // MARK: - Private properties

    private var scrollView: UIScrollView!
    private var itemsField: UITextFieldSelector<PickerIdValued<String>>!
    private var selectorsField: UITextFieldSelector<PickerIdValued<String>>!

    private var fullScreenChartManager = FullScreenChartViewManager()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Private methods

    private func setupUI() {

        setupNavigationUI()
        view.backgroundColor = .mainBackground

        scrollView = UIScrollView().then { scrollView in

            scrollView.showsVerticalScrollIndicator = false
            scrollView.backgroundColor = .neutral75

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
            view.onTap { }
            view.apply(selectedValue: .init(id: "ID", title: "Brent Swap", fullTitle: "Brent Swap"), placeholder: "Select item")
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
            view.onTap { }
            view.apply(selectedValue: .init(id: "ID", title: "Jan 22", fullTitle: "Jan 22"), placeholder: "Select item")
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

        let hlView = LCWebResultHLView().then { view in

            scrollViewContent.addSubview(view) {
                $0.left.right.equalToSuperview()
                $0.top.equalTo(selectorsStackView.snp.bottom).offset(8)
                $0.height.equalTo(55)
            }
        }

        let tradeViewContent = UIView().then { view in

            let tradeViewController = LCWebTradeViewController(buttonType: .expand)
            tradeViewController.delegate = self
            add(tradeViewController, to: view)

            scrollViewContent.addSubview(view) {
                $0.top.equalTo(hlView.snp.bottom).offset(1)
                $0.left.right.equalToSuperview()
                $0.height.equalTo(470)
            }
        }

        _ = LCWebHistoricalDataView().then { view in

            scrollViewContent.addSubview(view) {
                $0.left.right.equalToSuperview()
                $0.top.equalTo(tradeViewContent.snp.bottom).offset(1)
                $0.bottom.equalToSuperview()
            }
        }
    }

    private func setupNavigationUI() {
        navigationItem.title = nil

        let title = "MainTabsPage.LiveCharts.Title".localized
        navigationItem.leftBarButtonItem = UIBarButtonItemFactory.logoButton(title: title)
    }
}

extension LCWebViewController: ResultMonthSelectorDelegate {

    func resultMonthSelectorDidTapLeftButton(view: ResultMonthSelector) {
        //        contentPageVC.showPrevious()
    }

    func resultMonthSelectorDidTapRightButton(view: ResultMonthSelector) {
        //        contentPageVC.showNext()
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

    func lcWebTradeViewControllerDidTapSizeButton(_ viewController: LCWebTradeViewController, buttonType: LCWebTradeViewController.ButtonType) {
        fullScreenChartManager.show()
    }
}
