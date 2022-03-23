//
//  APPCDatesHeaderView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.10.2021.
//

import UIKit

class APPCDatesHeaderView: UIView {

    // MARK: - Private properties

    private let headers: [ArbsPlaygroundPCPUIModel.Header]

    // MARK: - Initializers

    init(headers: [ArbsPlaygroundPCPUIModel.Header]) {
        self.headers = headers
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
            stackView.distribution = .fillEqually
            stackView.spacing = APPCUIConstants.priceItemSpace
            stackView.alignment = .fill

            headers.forEach { header in
                _ = APPCDatesHeaderItemView(title: header.month.title,
                                            subTitle: header.units).then { view in

                    view.snp.makeConstraints {
                        $0.width.equalTo(70)
                    }
                    stackView.addArrangedSubview(view)
                }
            }

            addSubview(stackView) {
                $0.left.top.bottom.equalToSuperview()
                $0.height.equalTo(58)
            }
        }
    }
}
