//
//  LoaderView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 11.01.2021.
//

import UIKit

class LoaderView: UIView {

    // MARK: - UI

    private let loadingView = LoadingView()

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func startAnimating() {
        guard loadingView.superview == nil else { return }

        UIView.animate(withDuration: 0.1) {
            self.loadingView.alpha = 1
        }

        addSubview(loadingView) {
            $0.edges.equalToSuperview()
        }
        bringSubviewToFront(loadingView)
    }

    func stopAnimating() {
        guard loadingView.superview != nil else { return }

        UIView.animate(withDuration: 0.1) {
            self.loadingView.alpha = 0.0
        } completion: { _ in
            self.loadingView.removeFromSuperview()
        }
    }

    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = UIColor.clear
    }
}
