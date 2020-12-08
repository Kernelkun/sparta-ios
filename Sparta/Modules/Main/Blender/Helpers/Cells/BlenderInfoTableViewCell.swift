//
//  BlenderInfoTableViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 02.12.2020.
//

import UIKit

class BlenderInfoTableViewCell: UITableViewCell {

    // MARK: - UI

    private var titleLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var bottomLine: UIView!

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("BlenderGradeTableViewCell")
    }

    // MARK: - Public methods
    
    func apply(infoModel: BlenderMonthInfoModel, isSeasonalityOn: Bool, for indexPath: IndexPath) {
        titleLabel.text = infoModel.numberPoint.text.capitalized
        titleLabel.textColor = infoModel.numberPoint.textColor

        if indexPath.section % 2 == 0 { // even
            backgroundColor = UIBlenderConstants.evenLineBackgroundColor
        } else { // odd
            backgroundColor = UIBlenderConstants.oddLineBackgroundColor
        }

        guard isSeasonalityOn else {
            descriptionLabel.isHidden = true
            return
        }

        if let seasonalityPoint = infoModel.seasonalityPoint {
            descriptionLabel.isHidden = false

            descriptionLabel.text = seasonalityPoint.text.capitalized
            descriptionLabel.textColor = seasonalityPoint.textColor
        } else {
            descriptionLabel.isHidden = true
        }
    }

    // MARK: - Private methods

    private func setupUI() {

        selectedBackgroundView = UIView().then { $0.backgroundColor = .clear }
        tintColor = .controlTintActive

        titleLabel = UILabel().then { label in

            label.textAlignment = .left
            label.textColor = .white
            label.numberOfLines = 2
            label.font = .main(weight: .regular, size: 14)
        }

        descriptionLabel = UILabel().then { label in

            label.textAlignment = .left
            label.textColor = .white
            label.font = .main(weight: .regular, size: 14)
            label.numberOfLines = 1
        }

        _ = UIStackView().then { stackView in

            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(descriptionLabel)

            stackView.axis = .vertical
            stackView.alignment = .leading
            stackView.spacing = 8
            stackView.distribution = .fillProportionally

            contentView.addSubview(stackView) {
                $0.right.equalToSuperview().inset(8)
                $0.centerY.equalToSuperview()
                $0.left.equalToSuperview().offset(16)
            }
        }

        bottomLine = UIView().then { view in

            view.backgroundColor = UIBlenderConstants.tableSeparatorLineColor

            contentView.addSubview(view) {
                $0.height.equalTo(CGFloat.separatorWidth)
                $0.left.right.bottom.equalToSuperview()
            }
        }
    }
}
