//
//  ArbDetailPageViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.06.2021.
//

import UIKit
import NetworkingModels

protocol ArbDetailPageViewControllerDelegate: AnyObject {
    func arbDetailPageViewControllerDidChangeMargin(_ controller: ArbDetailPageViewController, margin: String)
}

class ArbDetailPageViewController: BaseViewController {

    // MARK: - Public properties

    weak var delegate: ArbDetailPageViewControllerDelegate?

    var mainBlock: LoaderView!
    var mainContentView: ArbDetailContentView!
    let loaderDelay = DelayObject(delayInterval: 0.1)

    // MARK: - UI

    private var contentScrollView: UIScrollView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI

        setupUI()
    }

    // MARK: - Private methods

    private func setupUI() {

        contentScrollView = UIScrollView().then { scrollView in

            scrollView.showsVerticalScrollIndicator = false

            addSubview(scrollView) {
                $0.top.equalToSuperview()
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

        // main block view

        setupMainBlock(in: scrollViewContent)
    }

    private func setupMainBlock(in contentView: UIView) {

        mainBlock = LoaderView().then { view in

            view.layer.cornerRadius = 8
            view.layer.masksToBounds = true

            mainContentView = ArbDetailContentView().then { mainContentView in

                mainContentView.backgroundColor = .clear

                mainContentView.onMarginChanged { [unowned self] text in
                    self.delegate?.arbDetailPageViewControllerDidChangeMargin(self, margin: text)
                }

                view.addSubview(mainContentView) {
                    $0.edges.equalToSuperview()
                }
            }

            contentView.addSubview(view) {
                $0.top.equalToSuperview().offset(8)
                $0.left.right.equalToSuperview().inset(24)
                $0.bottom.equalToSuperview()
            }
        }
    }
}
