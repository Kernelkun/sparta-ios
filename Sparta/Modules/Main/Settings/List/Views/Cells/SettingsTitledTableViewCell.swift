//
//  SettingsTitledTableViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.12.2020.
//

import UIKit
import SpartaHelpers

class SettingsTitledTableViewCell: UITableViewCell {

    // MARK: - UI

    private var titleLabel: UILabel!
    private var bottomLine: UIView!

    // MARK: - Private properties

    private var rowName: SettingsViewModel.RowName!
    private var _onTapClosure: TypeClosure<SettingsViewModel.RowName>?

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("BlenderGradeTableViewCell")
    }

    // MARK: - Public methods

    func apply(rowName: SettingsViewModel.RowName) {
        self.rowName = rowName
        titleLabel.text = rowName.displayName
    }

    func onTap(completion: @escaping TypeClosure<SettingsViewModel.RowName>) {
        _onTapClosure = completion
    }

    // MARK: - Private methods

    private func setupUI() {

        // general

        let backgroundColor = UIColor.white.withAlphaComponent(0.04)
        self.backgroundColor = backgroundColor
        selectedBackgroundView = UIView().then { $0.backgroundColor = backgroundColor }
        tintColor = UIColor.white.withAlphaComponent(0.5)
        accessoryType = .disclosureIndicator

        titleLabel = UILabel().then { label in

            label.textAlignment = .left
            label.textColor = .primaryText
            label.numberOfLines = 1
            label.font = .main(weight: .regular, size: 16)

            contentView.addSubview(label) {
                $0.left.equalToSuperview().offset(16)
                $0.bottom.top.equalToSuperview().inset(11)
            }
        }

        bottomLine = UIView().then { view in

            view.backgroundColor = UIBlenderConstants.tableSeparatorLineColor

            addSubview(view) {
                $0.height.equalTo(0.5)
                $0.left.right.bottom.equalToSuperview()
            }
        }

        // events
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapEvent)))
    }

    // MARK: - Events

    @objc
    private func onTapEvent() {
        _onTapClosure?(rowName)
    }
}
