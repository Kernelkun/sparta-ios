//
//  BaseTableViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 21.05.2021.
//

import UIKit
import Then

class BaseTableViewController: UITableViewController {

    // MARK: - Public properties

    var isFirstLoad: Bool { enterCount == 1 }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Private accessors

    private var enterCount: Int = 0

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        enterCount += 1
    }

    // MARK: - Private methods

    private func setupUI() {
        view.backgroundColor = UIColor.mainBackground
    }
}
