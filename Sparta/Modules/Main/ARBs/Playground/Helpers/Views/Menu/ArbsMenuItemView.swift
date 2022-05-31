//
//  ArbsMenuItemView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 26.10.2021.
//

import UIKit
import SpartaHelpers

class ArbsMenuItemView: TappableView {

    // MARK: - Public propeties

    let item: ArbsMenuView.MenuItem

    var isSelected: Bool {
        didSet { updateUI() }
    }

    // MARK: - Private properties

    private var titleLabel: UILabel!

    // MARK: - Initializers

    init(item: ArbsMenuView.MenuItem) {
        self.item = item
        self.isSelected = false
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

            addSubview(label) {
                $0.edges.equalToSuperview()
            }
        }

        updateUI()
    }

    private func updateUI() {
        if isSelected {
            titleLabel.textColor = .neutral35
            titleLabel.font = .main(weight: .medium, size: 14)
        } else {
            titleLabel.textColor = .neutral35.withAlphaComponent(0.7)
            titleLabel.font = .main(weight: .medium, size: 14)
        }
    }
}
