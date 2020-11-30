//
//  TestViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 30.11.2020.
//

import UIKit

class TestViewController: UIViewController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Private methods

    private func setupUI() {

        navigationItem.rightBarButtonItem = UIBarButtonItemFactory.titleButton(text: "Logout", onTap: { _ in
            App.instance.logout()
        })
    }
}
