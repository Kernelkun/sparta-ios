//
//  PopupViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 04.12.2020.
//

import UIKit

class PopupViewController: UIViewController {

    // MARK: - Initializers

    init() {
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func show(_ view: UIView) {

        addSubview(view) {
            $0.center.equalToSuperview()
            $0.width.equalTo(300)
            $0.height.equalTo(600)
        }

        UIViewController.topController?.present(self, animated: true, completion: nil)
    }
}
