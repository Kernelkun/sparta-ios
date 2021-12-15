//
//  MainSegmentedView+ItemView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 30.11.2021.
//

import UIKit
import SpartaHelpers

extension MainSegmentedView {

    class ItemView: TappableView {

        // MARK: - Public properties

        let item: MainSegmentedView.MenuItem

        // MARK: - Private properties

        private var titleLabel: UILabel!

        // MARK: - Initializers

        init(item: MainSegmentedView.MenuItem) {
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
                label.text = item.rawValue.capitalizedFirst
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
