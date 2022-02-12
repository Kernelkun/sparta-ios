//
//  TabMenuItemView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.02.2022.
//

import UIKit
import NetworkingModels
import SpartaHelpers

class TabMenuItemView: TappableView {

    // MARK: - Public properties

    let item: TabMenuItem

    var isActive: Bool = false {
        didSet { updateUI() }
    }

    // MARK: - Private propertiesO

    private var _tapClosure: TypeClosure<TabMenuItem>?

    private var imageView: UIImageView!
    private var titleLabel: UILabel!

    // MARK: - Initializers

    init(item: TabMenuItem) {
        self.item = item
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Private methods

    private func setupUI() {

        imageView = UIImageView().then { imageView in

            imageView.image = UIImage(named: item.imageName)
            imageView.contentMode = .center

            imageView.snp.makeConstraints {
                $0.size.equalTo(30)
            }
        }

        titleLabel = UILabel().then { label in

            label.text = item.title
            label.textColor = .primaryText
            label.textAlignment = .center
            label.font = .main(weight: .medium, size: 11)
        }

        _ = UIStackView().then { stackView in

            stackView.axis = .vertical
            stackView.spacing = 0
            stackView.distribution = .equalSpacing
            stackView.alignment = .center

            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(titleLabel)

            addSubview(stackView) {
                $0.left.right.equalToSuperview()
                $0.height.equalTo(45)
                $0.centerY.equalToSuperview()
            }
        }

        updateUI()
    }

    private func updateUI() {
        imageView.tintColor = isActive ? UIColor.controlTintActive : UIColor.neutral35
        titleLabel.textColor = isActive ? UIColor.controlTintActive : UIColor.neutral35
    }
}
