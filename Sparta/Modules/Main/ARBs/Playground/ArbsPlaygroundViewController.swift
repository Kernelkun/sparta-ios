//
//  ArbsPlaygroundViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 23.07.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers

class ArbsPlaygroundViewController: BaseVMViewController<ArbsPlaygroundViewModel> {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI

        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // navigation UI

        setupNavigationUI()

        // view model

        viewModel.loadData()
    }

    // MARK: - Private methods

    private func setupNavigationUI() {
        navigationItem.title = "ARBs Playground"
        navigationBar(hide: false)
    }

    private func setupUI() {

    }
}

extension ArbsPlaygroundViewController: ArbsPlaygroundViewModelDelegate {

    func didChangeLoadingState(_ isLoading: Bool) {
    }

    func didCatchAnError(_ error: String) {
    }
}

