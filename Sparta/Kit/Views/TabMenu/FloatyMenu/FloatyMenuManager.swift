//
//  FloatyMenuManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 11.02.2022.
//

import UIKit
import SpartaHelpers

class FloatyMenuManager {

    // MARK: - Private properties

    private var controller: FloatyMenuViewController?

    private var window: UIWindow?
    private var isPresented: Bool = false

    private var _onChooseClosure: TypeClosure<TabMenuItem>?
    private var _onHideClosure: EmptyClosure?

    // MARK: - Public methods

    func onChoose(completion: @escaping TypeClosure<TabMenuItem>) {
        _onChooseClosure = completion
    }

    func onHide(completion: @escaping EmptyClosure) {
        _onHideClosure = completion
    }

    func show(frame: CGRect, menuItemsCount: Int, tabs: [TabMenuItem]) {
        guard !isPresented else { return }

        isPresented = true

        controller = FloatyMenuViewController(tabs: tabs, menuItemsCount: menuItemsCount)

        controller?.onChoose { [unowned self] menuItem in
            _onChooseClosure?(menuItem)
        }

        controller?.onHide { [unowned self] in
            guard isPresented else { return }

            _onHideClosure?()
            isPresented = false
            window = nil
        }

        window = UIWindow(frame: frame)
        window?.rootViewController = controller
        window?.windowLevel = UIWindow.Level.normal + 2
        window?.makeKeyAndVisible()
    }

    func hide() {
        guard isPresented else { return }

        isPresented = false
        window = nil
    }
}
