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
        fatalError("APPCTableViewCell")
    }

    // MARK: - Private methods

    private func setupUI() {

        backgroundColor = .clear
        selectedBackgroundView = UIView().then { $0.backgroundColor = .mainBackground }
        tintColor = .controlTintActive
        selectionStyle = .none

        let lightsView1 = APPCLightsSetView()

        let lightsView2 = APPCLightsSetView()

        let lightsView3 = APPCLightsSetView()

        let lightsView4 = APPCLightsSetView()

        let lightsView5 = APPCLightsSetView()

        let lightsView6 = APPCLightsSetView()

        _ = UIStackView().then { stackView in

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
                $0.left.equalToSuperview().offset(APPCUIConstants.leftMenuWidth)
                $0.top.equalToSuperview().offset(8)
                $0.right.equalToSuperview()
                $0.bottom.equalToSuperview().inset(16)
            }
        }

        _ = UILabel().then { label in

            label.text = "Blender Mrg"
            label.textAlignment = .right
            label.textColor = .primaryText
            label.font = .main(weight: .regular, size: 11)
            label.numberOfLines = 0

            contentView.addSubview(label) {
                $0.centerY.equalTo(lightsView1)
                $0.right.equalTo(lightsView1.snp.left).offset(-APPCUIConstants.priceItemSpace)
            }
        }

        _ = UILabel().then { label in

            label.text = "NWE Ref Mrg"
            label.textAlignment = .right
            label.textColor = .primaryText
            label.font = .main(weight: .regular, size: 11)
            label.numberOfLines = 0

            contentView.addSubview(label) {
                $0.centerY.equalTo(lightsView2)
                $0.right.equalTo(lightsView1.snp.left).offset(-APPCUIConstants.priceItemSpace)
            }
        }

        _ = UILabel().then { label in

            label.text = "FOB ARA Ref Mrg"
            label.textAlignment = .right
            label.textColor = .primaryText
            label.font = .main(weight: .regular, size: 11)
            label.numberOfLines = 0

            contentView.addSubview(label) {
                $0.centerY.equalTo(lightsView3)
                $0.right.equalTo(lightsView1.snp.left).offset(-APPCUIConstants.priceItemSpace)
                $0.bottom.equalToSuperview()
            }
        }

        // identifier view

        let identifierView = APPCIdentifierView(title: "ara".uppercased(),
                                                subTitle: "lr1".uppercased()).then { view in

            addSubview(view) {
                $0.top.equalToSuperview().offset(8)
                $0.left.equalToSuperview().offset(8)
            }
        }
    }
}
