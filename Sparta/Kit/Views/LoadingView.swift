//
//  LoadingView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 15.12.2020.
//

import UIKit

class LoadingView: UIView {

    // MARK: - UI

    private var indicatorView: UIActivityIndicatorView!

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setupUI() {

        backgroundColor = UIColor.black.withAlphaComponent(0.5)

        indicatorView = UIActivityIndicatorView(style: .medium).then { view in

            view.tintColor = .controlTintActive
            view.startAnimating()

            addSubview(view) {
                $0.center.equalToSuperview()
            }
        }
    }

}
