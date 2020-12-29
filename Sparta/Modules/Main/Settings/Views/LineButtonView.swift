//
//  LineButtonView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 14.12.2020.
//

import UIKit
import SpartaHelpers

class LineButtonView: UIView {

    // MARK: - Private properties

    private let title: String
    private var _tapClosure: EmptyClosure?

    // MARK: - Initializers

    init(title: String) {
        self.title = title
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func onTap(completion: @escaping EmptyClosure) {
        _tapClosure = completion
    }

    // MARK: - Private methods

    private func setupUI() {

        _ = TappableView().then { view in

            _ = UILabel().then { label in

                label.textAlignment = .left
                label.textColor = .primaryText
                label.numberOfLines = 1
                label.font = .main(weight: .regular, size: 16)
                label.text = title
                label.isUserInteractionEnabled = true

                view.addSubview(label) {
                    $0.left.equalToSuperview().offset(16)
                    $0.bottom.top.equalToSuperview().inset(11)
                }
            }

            view.onTap { [unowned self] _ in
                self._tapClosure?()
            }

            view.backgroundColor = UIColor.white.withAlphaComponent(0.04)

            addSubview(view) {
                $0.edges.equalToSuperview()
            }
        }
    }
}
