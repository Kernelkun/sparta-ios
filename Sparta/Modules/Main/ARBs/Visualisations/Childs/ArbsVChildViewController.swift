//
//  ArbsVChildViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 15.12.2021.
//

import UIKit

class ArbsVChildViewController: BaseViewController, ArbsVContentControllerObserver {

    // MARK: - Public properties

    let parrentController: ArbsVContentControllerInterface

    // MARK: - Initializers

    init(parrentController: ArbsVContentControllerInterface) {
        self.parrentController = parrentController
        super.init(nibName: nil, bundle: nil)

        parrentController.addObserver(self)
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    deinit {
        parrentController.removeObserver(self)
    }

    // MARK: - ArbsVContentControllerObserver

    func arbsVContentControllerDidChangeScrollState(_ controller: ArbsVContentControllerInterface, newState: State) {

    }
}
