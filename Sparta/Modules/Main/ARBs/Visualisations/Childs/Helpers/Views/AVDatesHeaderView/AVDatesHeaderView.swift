//
//  AVDatesHeaderView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.10.2021.
//

import UIKit

class AVDatesHeaderView: UIView {

    // MARK: - Private properties

    private let configurator: Configurator

    // MARK: - Initializers

    init(configurator: Configurator) {
        self.configurator = configurator
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Private methods

    private func setupUI() {

        _ = UIStackView().then { stackView in

            stackView.axis = .horizontal
            stackView.distribution = .equalSpacing
            stackView.spacing = configurator.itemSpace
            stackView.alignment = .fill

            configurator.headers.forEach { header in
                _ = AVDatesHeaderItemView(
                    title: header.title,
                    subTitle: header.subTitle
                ).then { view in
                    view.snp.makeConstraints {
                        $0.width.equalTo(configurator.itemWidth)
                    }
                    stackView.addArrangedSubview(view)
                }
            }

            addSubview(stackView) {
                $0.edges.equalToSuperview()
                $0.height.equalTo(58)
            }
        }
    }
}
