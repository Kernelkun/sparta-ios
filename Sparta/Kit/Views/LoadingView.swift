//
//  LoadingView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 15.12.2020.
//

import UIKit
import NVActivityIndicatorView

class LoadingView: UIView {

    // MARK: - UI

    private var loader: NVActivityIndicatorView!

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

        // loader

        loader = NVActivityIndicatorView(frame: .zero).then { view in
            view.type = .lineScale
            view.color = .controlTintActive
            view.startAnimating()

            addSubview(view) {
                $0.width.height.equalTo(22)
                $0.center.equalToSuperview()
            }
        }
    }
}
