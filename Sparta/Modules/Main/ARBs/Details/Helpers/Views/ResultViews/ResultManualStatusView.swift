//
//  ResultManualStatusView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.01.2021.
//

import UIKit
import SpartaHelpers
import NetworkingModels

class ResultManualStatusView: UIView {

    // MARK: - UI

    private var keyLabel: UILabel!

    // MARK: - Private properties

    private var _textChangeClosure: TypeClosure<String>?

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

        backgroundColor = .clear

        keyLabel = UILabel().then { label in

            label.text = "ArbDetailPage.Button.InputTgt.Title".localized
            label.font = .main(weight: .regular, size: 17)
            label.textColor = .controlTintActive
            label.textAlignment = .left

            addSubview(label) {
                $0.left.equalToSuperview().offset(8)
                $0.centerY.equalToSuperview()
            }
        }
    }
}
