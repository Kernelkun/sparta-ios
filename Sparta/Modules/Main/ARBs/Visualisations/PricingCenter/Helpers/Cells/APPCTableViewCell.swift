//
//  APPCTableViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.10.2021.
//

import UIKit

class APPCTableViewCell: UITableViewCell {

    // MARK: - UI

    private var titleLabel: UILabel!

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Private methods

    private func setupUI() {

        backgroundColor = .clear
        selectedBackgroundView = UIView().then { $0.backgroundColor = .mainBackground }
        tintColor = .controlTintActive
        selectionStyle = .none

        // identifier view

        let identifierView = APPCIdentifierView(
            title: "ara".uppercased(),
            subTitle: "lr1".uppercased()
        )

        // labels

        let firstLabel = UILabel().then { label in

            label.text = "Blender Mrg"
            label.textAlignment = .right
            label.textColor = .primaryText
            label.font = .main(weight: .regular, size: 11)
            label.numberOfLines = 0

            label.snp.makeConstraints {
                $0.height.equalTo(40)
            }
        }

        let secondLabel = UILabel().then { label in

            label.text = "NWE Ref Mrg"
            label.textAlignment = .right
            label.textColor = .primaryText
            label.font = .main(weight: .regular, size: 11)
            label.numberOfLines = 0

            label.snp.makeConstraints {
                $0.height.equalTo(40)
            }
        }

        let thirdLabel = UILabel().then { label in

            label.text = "FOB ARA Ref Mrg"
            label.textAlignment = .right
            label.textColor = .primaryText
            label.font = .main(weight: .regular, size: 11)
            label.numberOfLines = 0

            label.snp.makeConstraints {
                $0.height.equalTo(40)
            }
        }

        let labelsStackView = UIStackView().then { stackView in

            stackView.axis = .vertical
            stackView.distribution = .equalSpacing
            stackView.spacing = APPCUIConstants.priceItemsLineSpace
            stackView.alignment = .fill

            stackView.addArrangedSubview(firstLabel)
            stackView.addArrangedSubview(secondLabel)
            stackView.addArrangedSubview(thirdLabel)
        }

        let leftContentView = UIView().then { view in

            view.addSubview(identifierView) {
                $0.top.equalToSuperview().offset(8)
                $0.left.equalToSuperview().offset(8)
                $0.size.equalTo(CGSize(width: 50, height: 38))
            }

            view.addSubview(labelsStackView) {
                $0.left.equalTo(identifierView.snp.right).offset(8)
                $0.bottom.equalToSuperview()
                $0.top.equalToSuperview().offset(8)
                $0.right.equalToSuperview().inset(8)
            }

            contentView.addSubview(view) {
                $0.top.left.equalToSuperview()
                $0.bottom.equalToSuperview().inset(16)
                $0.width.equalTo(APPCUIConstants.leftMenuWidth)
            }
        }

        // mains views

        let lightsView1 = APPCLightsSetView()
        let lightsView2 = APPCLightsSetView()
        let lightsView3 = APPCLightsSetView()
        let lightsView4 = APPCLightsSetView()
        let lightsView5 = APPCLightsSetView()
        let lightsView6 = APPCLightsSetView()

        let numbersStackView = UIStackView().then { stackView in

            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = APPCUIConstants.priceItemSpace
            stackView.alignment = .fill

            stackView.addArrangedSubview(lightsView1)
            stackView.addArrangedSubview(lightsView2)
            stackView.addArrangedSubview(lightsView3)
            stackView.addArrangedSubview(lightsView4)
            stackView.addArrangedSubview(lightsView5)
            stackView.addArrangedSubview(lightsView6)

            contentView.addSubview(stackView) {
                $0.top.equalToSuperview().offset(8)
                $0.left.equalTo(leftContentView.snp.right)
                $0.right.equalToSuperview()
                $0.bottom.equalToSuperview().inset(16)
            }
        }
    }
}
