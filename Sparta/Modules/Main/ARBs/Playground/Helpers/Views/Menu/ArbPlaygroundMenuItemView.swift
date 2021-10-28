//
//  ArbPlaygroundMenuItemView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 26.10.2021.
//

import UIKit
import SpartaHelpers

class ArbPlaygroundMenuItemView: TappableView {

    // MARK: - Private properties

    private let systemImageName: String
    private let title: String

    // MARK: - Initializers

    init(systemImageName: String, title: String) {
        self.systemImageName = systemImageName
        self.title = title
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setupUI() {
        let imageView = prepareImageView()

        let titleLabel = UILabel().then { titleLabel in

            titleLabel.textAlignment = .center
            titleLabel.textColor = UIColor.secondaryText
            titleLabel.font = .main(weight: .regular, size: 11)
            titleLabel.numberOfLines = 0
            titleLabel.text = title
            titleLabel.lineBreakMode = .byWordWrapping
        }

        _ = UIStackView().then { stackView in

            stackView.axis = .vertical
            stackView.distribution = .equalSpacing
            stackView.spacing = 0
            stackView.alignment = .fill

            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(titleLabel)

            addSubview(stackView) {
                $0.edges.equalToSuperview()
            }
        }
    }

    private func prepareImageView() -> UIView {
        UIView().then { view in

            _ = UIImageView().then { imageView in

                let imageConfiguration = UIImage.SymbolConfiguration(weight: .bold)
                let image = UIImage(systemName: systemImageName,
                                    withConfiguration: imageConfiguration)

                let imageView = UIImageView(image: image)
                imageView.tintColor = .secondaryText
                imageView.isUserInteractionEnabled = true

                view.addSubview(imageView) {
                    $0.center.equalToSuperview()
                }
            }

            view.snp.makeConstraints {
                $0.size.equalTo(35)
            }
        }
    }
}
