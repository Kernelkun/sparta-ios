//
//  TappableView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import UIKit
import SpartaHelpers

class TappableView: UIView {

    // MARK: - Private accessors

    private var onTapClosure: TypeClosure<UIView>?

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupEvents()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupEvents()
    }

    // MARK: - Public methods

    func onTap(completion: @escaping TypeClosure<UIView>) {
        onTapClosure = completion
    }

    // MARK: - Private methods

    private func setupEvents() {

        // gesture

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapEvent)))
    }

    // MARK: - Events

    @objc
    private func onTapEvent() {
        onTapClosure?(self)
    }
}
