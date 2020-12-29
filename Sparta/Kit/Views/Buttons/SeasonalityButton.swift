//
//  SeasonalityButton.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 21.12.2020.
//

import UIKit
import SpartaHelpers

class SeasonalityButton: BiggerAreaButton {

    // MARK: - Public properties

    private(set) var isActive: Bool = false {
        didSet {
            updateUI()
        }
    }

    // MARK: - Private properties

    private var _tapEventClosure: TypeClosure<Bool>?

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupUI()
    }

    // MARK: - Public methods

    func onTap(completion: @escaping TypeClosure<Bool>) {
        _tapEventClosure = completion
    }

    // MARK: - Private methods

    private func setupUI() {

        // general

        setBackgroundImage(UIImage(named: "ic_seasonality"), for: .normal)

        // actions

        addTarget(self, action: #selector(tapEvent), for: .touchUpInside)
    }

    private func updateUI() {

        if isActive {
            setBackgroundImage(UIImage(named: "ic_seasonality")?.withTintColor(.controlTintActive),
                               for: .normal)
        } else {
            setBackgroundImage(UIImage(named: "ic_seasonality"),for: .normal)
        }
    }

    // MARK: - Events

    @objc
    private func tapEvent() {
        isActive.toggle()
        _tapEventClosure?(isActive)
    }
}

