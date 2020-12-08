//
//  TappableUISwitch.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 06.12.2020.
//

import UIKit
import SpartaHelpers

class TappableUISwitch: UISwitch {

    // MARK: - Private properties

    private var _onValueChangedClosure: TypeClosure<Bool>?

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func onValueChanged(completion: @escaping TypeClosure<Bool>) {
        _onValueChangedClosure = completion
    }

    // MARK: - Private methods

    private func setup() {

        // events

        addTarget(self, action: #selector(onChangeStateEvent), for: .valueChanged)

        // general UI

        onTintColor = .controlTintActive
    }

    // MARK: - Events

    @objc
    private func onChangeStateEvent() {
        _onValueChangedClosure?(isOn)
    }
}
