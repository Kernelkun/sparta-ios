//
//  ResultAutoStatusView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.01.2021.
//

import UIKit
import SpartaHelpers
import NetworkingModels

class ResultAutoStatusView<T: Hashable>: UIView, Identifiable {

    var id: T

    // MARK: - UI

    private var keyLabel: UILabel!
    private var progressView: ProgressView!

    // MARK: - Private properties

    private var _textChangeClosure: TypeClosure<String>?

    // MARK: - Initializers

    init(id: T) {
        self.id = id
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func apply(key: String, position: ArbMonth.Position?) {
        if let position = position {
            setupProgressView()
            keyLabel.text = key
            progressView.apply(progressPercentage: position.percentage, color: position.color)
        } else {
            setupInputTargetView()
        }
    }

    // MARK: - Private methods

    private func setupInputTargetView() {
        removeAllSubviews()

        backgroundColor = .clear

        keyLabel = UILabel().then { label in

            label.text = "Input My Target"
            label.font = .main(weight: .regular, size: 17)
            label.textColor = .controlTintActive
            label.textAlignment = .left

            addSubview(label) {
                $0.left.equalToSuperview().offset(8)
                $0.centerY.equalToSuperview()
            }
        }
    }

    private func setupProgressView() {
        removeAllSubviews()

        backgroundColor = UIColor.accountFieldBackground
        layer.cornerRadius = 4

        keyLabel = UILabel().then { label in

            label.font = .main(weight: .regular, size: 17)
            label.textColor = .accountMainText
            label.textAlignment = .center

            addSubview(label) {
                $0.left.equalToSuperview().offset(8)
                $0.centerY.equalToSuperview()
            }
        }

        progressView = ProgressView().then { progressView in

            addSubview(progressView) {
                $0.width.equalTo(67)
                $0.height.equalTo(8)
                $0.right.equalToSuperview().inset(8)
                $0.centerY.equalToSuperview()
            }
        }
    }
}
