//
//  FreightResultPageViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 11.06.2021.
//

import UIKit
import NetworkingModels

class FreightResultPageViewController: BaseViewController {

    // MARK: - UI

    var contentScrollView: UIScrollView!
    var mainBlock: LoaderView!
    var mainTopStackView: UIStackView!
    var mainBottomStackView: UIStackView!
    let loaderDelay = DelayObject(delayInterval: 0.1)

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

            view.backgroundColor = .barBackground
            view.layer.cornerRadius = 8
            view.layer.masksToBounds = true

            mainTopStackView = UIStackView().then { stackView in

                stackView.axis = .vertical
                stackView.distribution = .equalSpacing
                stackView.spacing = 9
                stackView.alignment = .fill

                view.addSubview(stackView) {
                    $0.left.top.right.equalToSuperview().inset(8)
                }
            }

            mainBottomStackView = UIStackView().then { stackView in

                stackView.axis = .vertical
                stackView.distribution = .equalSpacing
                stackView.spacing = 9
                stackView.alignment = .fill

                view.addSubview(stackView) {
                    $0.left.bottom.right.equalToSuperview().inset(8)
                    $0.top.equalTo(mainTopStackView.snp.bottom).offset(18)
                }
            }

            contentView.addSubview(view) {
                $0.top.equalToSuperview().offset(8)
                $0.left.right.equalToSuperview().inset(8)
                $0.bottom.equalToSuperview()
            }
        }
    }
}
