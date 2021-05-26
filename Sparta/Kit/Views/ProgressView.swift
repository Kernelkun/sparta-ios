//
//  ProgressView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.01.2021.
//

import UIKit

class ProgressView: UIView {

    // MARK: - UI

    private var contentView: UIView!
    private var _oldFrame: CGRect = .zero

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()

        if _oldFrame != frame {
            let radius = frame.height / 2

            layer.cornerRadius = radius
            contentView.layer.cornerRadius = radius

            _oldFrame = frame
        }
    }

    // MARK: - Public methods

    func apply(progressPercentage: Double, color: UIColor) {
        contentView.backgroundColor = color
        contentView.snp.remakeConstraints {
            $0.left.top.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(progressPercentage / 100)
        }
    }

    // MARK: - Private methods

    private func setupUI() {

        // general

        backgroundColor = UIColor(hex: 0x4D4D4D)
        layer.masksToBounds = true

        // subviews

        contentView = UIView().then { view in

            view.backgroundColor = .clear

            addSubview(view) {
                $0.left.top.bottom.equalToSuperview()
                $0.width.equalTo(0)
            }
        }
    }
}
