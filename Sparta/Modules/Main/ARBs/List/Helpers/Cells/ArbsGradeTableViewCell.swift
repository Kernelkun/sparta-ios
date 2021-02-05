//
//  ArbsGradeTableViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 21.01.2021.
//

import UIKit
import SpartaHelpers

class ArbsGradeTableViewCell: UITableViewCell {

    // MARK: - UI

    private var titleLabel: UILabel!
    private var firstDescriptionLabel: UILabel!
    private var secondDescriptionLabel: UILabel!
    private var bottomLine: UIView!

    // MARK: - Public accessors

    var indexPath: IndexPath!

    // MARK: - Private accessors

    private var _tapClosure: TypeClosure<IndexPath>?

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("ArbsGradeTableViewCell")
    }

    // MARK: - Public methods

    func onTap(completion: @escaping TypeClosure<IndexPath>) {
        _tapClosure = completion
    }

    func apply(text: NSAttributedString, for indexPath: IndexPath) {
        self.indexPath = indexPath

        titleLabel.attributedText = text

        if indexPath.section % 2 == 0 { // even
            backgroundColor = UIGridViewConstants.oddLineBackgroundColor
        } else { // odd
            backgroundColor = UIGridViewConstants.evenLineBackgroundColor
        }
    }

    // MARK: - Private methods

    private func setupUI() {

        selectedBackgroundView = UIView().then { $0.backgroundColor = .clear }
        tintColor = .controlTintActive

        titleLabel = UILabel().then { label in

            label.textAlignment = .left
            label.textColor = .white
            label.numberOfLines = 3
        }

        _ = UIStackView().then { stackView in

            stackView.addArrangedSubview(titleLabel)

            stackView.axis = .vertical
            stackView.alignment = .leading
            stackView.spacing = 8
            stackView.distribution = .fillProportionally

            contentView.addSubview(stackView) {
                $0.right.equalToSuperview()
                $0.left.equalToSuperview().offset(8)
                $0.centerY.equalToSuperview()
            }
        }

        bottomLine = UIView().then { view in

            view.backgroundColor = UIGridViewConstants.tableSeparatorLineColor

            contentView.addSubview(view) {
                $0.height.equalTo(CGFloat.separatorWidth)
                $0.left.right.bottom.equalToSuperview()
            }
        }

        // actions

        setupActions()
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
