//
//  LCWebViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 03.02.2022.
//

import UIKit

class LCWebViewController: UIViewController {

    // MARK: - Private properties

    private var scrollView: UIScrollView!
    private var itemsField: UITextFieldSelector<PickerIdValued<String>>!
    private var monthSelector: ResultMonthSelector!

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
                $0.top.equalToSuperview().offset(topBarHeight + 12)
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

        let itemsLabel = UILabel().then { label in

            label.text = "LiveCharts.ItemsField.Title".localized
            label.textColor = .neutral00
            label.font = .main(weight: .regular, size: 14)
            label.numberOfLines = 0

            scrollViewContent.addSubview(label) {
                $0.top.equalToSuperview().offset(16)
                $0.left.equalToSuperview().offset(16)
            }
        }

        itemsField = UITextFieldSelector().then { view in

            view.backgroundColor = .neutral85
            view.onTap { }
            view.apply(selectedValue: .init(id: "ID", title: "Brent Swap", fullTitle: "Brent Swap"), placeholder: "Select item")

            scrollViewContent.addSubview(view) {
                $0.top.equalTo(itemsLabel.snp.bottom)
                $0.left.right.equalToSuperview().inset(16)
                $0.height.equalTo(48)
            }
        }

        monthSelector = ResultMonthSelector().then { view in

            view.backgroundColor = .neutral85
            view.delegate = self
            view.titleText = "September 2021"
            view.isEnabledLeftButton = false
            view.isEnabledRightButton = false

            scrollViewContent.addSubview(view) {
                $0.top.equalTo(itemsField.snp.bottom).offset(16)
                $0.left.right.equalToSuperview().inset(16)
                $0.height.equalTo(35)
            }
        }

        let tradeViewContent = UIView().then { view in

            let tradeViewController = LCWebTradeViewController()
            tradeViewController.delegate = self
            add(tradeViewController, to: view)

            scrollViewContent.addSubview(view) {
                $0.top.equalTo(monthSelector.snp.bottom).offset(16)
                $0.left.right.equalToSuperview()
                $0.height.equalTo(432)
            }
        }

        let hlView = LCWebResultHLView().then { view in

            scrollViewContent.addSubview(view) {
                $0.left.right.equalToSuperview().inset(16)
                $0.top.equalTo(tradeViewContent.snp.bottom).offset(16)
                $0.height.equalTo(56)
            }
        }

        _ = LCWebHistoricalDataView().then { view in

            scrollViewContent.addSubview(view) {
                $0.left.right.equalToSuperview().inset(16)
                $0.top.equalTo(hlView.snp.bottom).offset(16)
                $0.bottom.equalToSuperview().inset(16)
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
}
