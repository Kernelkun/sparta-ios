//
//  TappableView.swift
//  
//
//  Created by Yaroslav Babalich on 21.01.2021.
//

import UIKit

open class TappableView: UIView {

    // MARK: - Private accessors

    private var onTapClosure: TypeClosure<UIView>?

    // MARK: - Initializers

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setupEvents()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        setupEvents()
    }

    // MARK: - Public methods

    public func onTap(completion: @escaping TypeClosure<UIView>) {
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
