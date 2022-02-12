//
//  FloatyMenuManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 11.02.2022.
//

import UIKit

class FloatyMenuManager {

    // MARK: - Private properties

    private var window: UIWindow?
    private var isPresented: Bool = false

    // MARK: - Public methods

    func show(frame: CGRect, tabs: [TabMenuItem]) {
        guard !isPresented else { return }

        isPresented = true

        /*func close(completion: @escaping EmptyClosure) {
            UIView.animate(withDuration: 0.1) {
                self.window?.alpha = 0.0
            } completion: { _ in
                self.window?.isHidden = true
                self.window = nil
                completion()
            }
        }*/

        let controller = FloatyMenuViewController(tabs: tabs)

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
