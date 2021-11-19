//
//  ProfileDescription.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 07.10.2021.
//

import UIKit

class ProfileDescription: CollapsableView {

    // MARK: - Private properties

    private var descriptionView = DescriptionView()

    // MARK: - Initializers

    init() {
        super.init(constructor: .init(isUserInteractable: false,
                                      isCollapsed: true,
                                      minView: UIView(),
                                      maxView: descriptionView))

        backgroundColor = UIGridViewConstants.mainBackgroundColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func show(text: String) {
        switchToState(isCollapsed: false, animated: false)
        descriptionView.show(text: text)
    }

    func hide() {
        switchToState(isCollapsed: true, animated: false)
        descriptionView.show(text: "")
    }
}

extension ProfileDescription {

    class DescriptionView: UIView {

        // MARK: - Private properties

        private var titleLabel: UILabel!

        // MARK: - Initializers

        init() {
            super.init(frame: .zero)

            setupUI()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Public methods

        func show(text: String) {
            titleLabel.text = text
        }

        // MARK: - Private methods

        private func setupUI() {
            titleLabel = UILabel().then { label in

                label.font = .main(weight: .regular, size: 11)
                label.numberOfLines = 2
                label.minimumScaleFactor = 0.2
                label.textAlignment = .left
                label.textColor = UIColor.accountMainText

                addSubview(label) {
                    $0.left.right.equalToSuperview().inset(20)
                    $0.top.bottom.equalToSuperview()
                }
            }
        }
    }
}
