//
//  BaseTableVMViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 14.05.2021.
//

import UIKit

class BaseTableVMViewController<Model: NSObject & BaseViewModel>: BaseTableViewController {

    // MARK: - Public properties

    private(set) var viewModel: Model! {
        didSet { viewModel.delegate = self as? Model.Controller }
    }

    // MARK: - Initializers

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        viewModel = Model()
        viewModel.delegate = self as? Model.Controller
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
