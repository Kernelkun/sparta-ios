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
    private var keyButton: TappableButton!
    private var progressView: ProgressView!

    // MARK: - Private properties

    private let sideInset: CGFloat
    private var _onInputTgtTapClosure: EmptyClosure?
    private var _textChangeClosure: TypeClosure<String>?

    // MARK: - Initializers

    init(id: T, sideInset: CGFloat) {
        self.id = id
        self.sideInset = sideInset
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func apply(position: ArbMonth.Position?) {
        if let position = position {
            setupProgressView()
            progressView.apply(progressPercentage: position.percentage, color: position.color)
        } else {
            setupInputTargetView()
        }
    }

    func onInputTgtTap(completion: @escaping EmptyClosure) {
        _onInputTgtTapClosure = completion
    }

    // MARK: - Private methods

    private func setupInputTargetView() {
        removeAllSubviews()

        keyButton = TappableButton().then { button in

            button.setTitle("ArbDetailPage.Button.InputTgt.Title".localized, for: .normal)
            button.setTitleColor(.controlTintActive, for: .normal)
            button.titleLabel?.font = .main(weight: .regular, size: 17)
            button.titleLabel?.textAlignment = .left

            button.onTap { [unowned self] _ in
                self._onInputTgtTapClosure?()
            }

            addSubview(button) {
                $0.left.equalToSuperview().offset(sideInset)
                $0.centerY.equalToSuperview()
            }
        }
    }

    private func setupProgressView() {
        removeAllSubviews()

        keyLabel = UILabel().then { label in

            label.text = "ArbDetailPage.Key.Status.Title".localized
            label.font = .main(weight: .regular, size: 17)
            label.textColor = .accountMainText
            label.textAlignment = .center

            addSubview(label) {
                $0.left.equalToSuperview().offset(sideInset)
                $0.centerY.equalToSuperview()
            }
        }

        progressView = ProgressView().then { progressView in

            addSubview(progressView) {
                $0.width.equalTo(67)
                $0.height.equalTo(8)
                $0.right.equalToSuperview().inset(22)
                $0.centerY.equalToSuperview()
            }
        }
    }
}
