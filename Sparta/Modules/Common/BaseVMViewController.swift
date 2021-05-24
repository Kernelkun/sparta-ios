//
//  BaseVMViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import UIKit

protocol BaseViewModel: AnyObject {

    associatedtype Controller
    var delegate: Controller? { get set }
}

class BaseVMViewController<Model: NSObject & BaseViewModel>: BaseViewController {

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
