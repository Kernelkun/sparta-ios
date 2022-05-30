//
//  MainSegmentedView+ItemView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 30.11.2021.
//

import UIKit
import SpartaHelpers
import NetworkingModels

extension MainSegmentedView {

    class ItemView<I: DisplayableItem>: TappableView {

        // MARK: - Public properties

        let item: I

        // MARK: - Private properties

        private var titleLabel: UILabel!

        // MARK: - Initializers

        init(item: I) {
            self.item = item
            super.init(frame: .zero)

            setupUI()
        }

        required init?(coder: NSCoder) {
            fatalError(#function)
        }

        // MARK: - Private methods

        private func setupUI() {
            titleLabel = UILabel().then { label in

                label.textAlignment = .center
                label.numberOfLines = 0
                label.text = item.title.capitalizedFirst
                label.isUserInteractionEnabled = false
                label.font = .main(weight: .semibold, size: 12)

                addSubview(label) {
                    $0.top.bottom.equalToSuperview()
                    $0.left.right.equalToSuperview().inset(12)
                }
            }
        }
    }
}
