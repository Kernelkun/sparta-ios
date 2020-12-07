//
//  PopupViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 04.12.2020.
//

import UIKit
import SnapKit

class PopupViewController: UIViewController {

    // MARK: - Public properties

    var backgroundAlpha: CGFloat = 0.2 {
        didSet {
            backgroundContentView?.alpha = backgroundAlpha
        }
    }

    var contentView: UIView?
    var backgroundContentView: UIView?

    // MARK: - Initializers

    init() {
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func show(_ view: UIView, makeConstraints: (ConstraintMaker) -> Void) {

        addSubview(view) { makeConstraints($0) }

        contentView = view

        UIViewController.topController?.present(self, animated: true, completion: nil)
    }

    func hide() {
        dismiss(animated: true) {
            self.contentView?.removeFromSuperview()
        }
    }

    // MARK: - Private methods

    private func setupUI() {

        backgroundContentView = UIView().then { view in

            view.backgroundColor = UIColor.black.withAlphaComponent(backgroundAlpha)

            addSubview(view) {
                $0.edges.equalToSuperview()
            }
        }
    }
}
