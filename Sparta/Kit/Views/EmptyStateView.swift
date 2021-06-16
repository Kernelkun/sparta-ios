//
//  EmptyStateView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 07.06.2021.
//

import UIKit
import SpartaHelpers

class EmptyStateView: UIView {

    // MARK: - Private properties

    private let titleText: String
    private let buttonText: String

    private var _buttonTapClosure: EmptyClosure?

    // MARK: - Initializers

    init(titleText: String, buttonText: String) {
        self.titleText = titleText
        self.buttonText = buttonText
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("EmptyStateView")
    }

    // MARK: - Public methods

    func onButtonTap(completion: @escaping EmptyClosure) {
        _buttonTapClosure = completion
    }

    // MARK: - Private methods

    private func setupUI() {

        let imageView = UIImageView().then { imageView in

            imageView.image = UIImage(named: "img_empty_state")

            addSubview(imageView) {
                $0.size.equalTo(CGSize(width: 128, height: 116))
                $0.centerX.equalToSuperview()
                $0.centerY.equalToSuperview().offset(-128)
            }
        }

        let titleLabel = UILabel().then { label in

            label.font = .main(weight: .semibold, size: 17)
            label.textAlignment = .center
            label.textColor = .primaryText
            label.text = titleText

            addSubview(label) {
                $0.centerX.equalTo(imageView)
                $0.top.equalTo(imageView.snp.bottom).offset(32)
            }
        }

        _ = BorderedButton(type: .custom).then { button in

            button.setTitle(buttonText, for: .normal)
            button.layer.cornerRadius = 3
            button.contentEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)

            button.onTap { [unowned self] _ in
                self._buttonTapClosure?()
            }

            addSubview(button) {
                $0.height.equalTo(32)
                $0.centerX.equalTo(titleLabel)
                $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            }
        }
    }
}
