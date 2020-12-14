//
//  BlenderInfoCollectionViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 02.12.2020.
//

import UIKit
import SpartaHelpers

class BlenderInfoCollectionViewCell: UICollectionViewCell {

    // MARK: - UI

    private var titleLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var bottomLine: UIView!

    private var _tapClosure: TypeClosure<IndexPath>?
    private var indexPath: IndexPath!

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
        setupActions()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func apply(infoModel: BlenderMonthInfoModel, isSeasonalityOn: Bool, for indexPath: IndexPath) {
        self.indexPath = indexPath

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

    func onTap(completion: @escaping TypeClosure<IndexPath>) {
        _tapClosure = completion
    }

    // MARK: - Private methods

    private func setupUI() {

        selectedBackgroundView = UIView().then { $0.backgroundColor = .clear }
        tintColor = .controlTintActive

        titleLabel = UILabel().then { label in

            label.textAlignment = .center
            label.textColor = .white
            label.font = .main(weight: .regular, size: 14)
            label.isUserInteractionEnabled = true
        }

        descriptionLabel = UILabel().then { label in

            label.textAlignment = .center
            label.textColor = .white
            label.font = .main(weight: .regular, size: 14)
            label.numberOfLines = 3
            label.isUserInteractionEnabled = true
        }

        _ = UIStackView().then { stackView in

            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(descriptionLabel)

            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 8
            stackView.distribution = .fillProportionally

            contentView.addSubview(stackView) {
                $0.left.right.equalToSuperview()
                $0.centerY.equalToSuperview()
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

    private func setupActions() {
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapEvent)))
    }

    // MARK: - Events

    @objc
    private func tapEvent() {
        _tapClosure?(indexPath)
    }
}
