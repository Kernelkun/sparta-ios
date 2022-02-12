//
//  FloatyMenuViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 11.02.2022.
//

import UIKit

class FloatyMenuViewController: UIViewController {

    // MARK: - Private properties

    private let tabs: [TabMenuItem]

    // MARK: - UI

    private var menuView: FloatyMenuView!

    // MARK: - Initializers

    init(tabs: [TabMenuItem]) {
        self.tabs = tabs
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Private methods

    private func setupUI() {
        view.backgroundColor = .clear

        menuView = FloatyMenuView().then { view in

            view.apply(items: tabs)

            addSubview(view) {
                $0.right.equalToSuperview().inset(12)
                $0.bottom.equalToSuperview().inset(14)
            }
        }
    }
}
