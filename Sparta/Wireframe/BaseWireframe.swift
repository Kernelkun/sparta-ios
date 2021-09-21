//
//  BaseWireframe.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 09.08.2021.
//

import UIKit

class BaseWireframe<ViewController> where ViewController: UIViewController {
    private unowned var _viewController: ViewController

    // to retain view controller reference upon first access
    private var temporaryStoredViewController: ViewController?

    init(viewController: ViewController) {
        temporaryStoredViewController = viewController
        _viewController = viewController
    }
}

extension BaseWireframe {
    var viewController: ViewController {
        defer { temporaryStoredViewController = nil }
        return _viewController
    }

    var navigationController: UINavigationController? {
        return viewController.navigationController
    }
}
