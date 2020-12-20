//
//  BlenderInfoCollectionViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 02.12.2020.
//

import UIKit
import SpartaHelpers
import NetworkingModels

class BlenderInfoCollectionViewCell: UICollectionViewCell {

    // MARK: - UI

    private var titleLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var contentStackView: UIStackView!
    private var bottomLine: UIView!

    // MARK: - Private properties

    private var month: BlenderMonth!
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

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()

        clearUI()
        stopObservingAllBlendersEvents()
    }

    // MARK: - Public methods

    func apply(month: BlenderMonth, isSeasonalityOn: Bool, for indexPath: IndexPath) {
        self.month = month
        self.indexPath = indexPath

        stopObservingAllBlendersEvents()
        observeBlenderMonth(for: month.observableName)

        titleLabel.text = self.month.value
        titleLabel.textColor = self.month.textColor
        descriptionLabel.text = self.month.seasonality

        if isSeasonalityOn {
            applyDescriptionUI()
        } else {
            applyTitledUI()
        }

        print("-month: \(month.observableName), \(month.seasonality)")

        if indexPath.section % 2 == 0 { // even
            backgroundColor = UIGridViewConstants.oddLineBackgroundColor
        } else { // odd
            backgroundColor = UIGridViewConstants.evenLineBackgroundColor
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
            label.textColor = .gray
            label.font = .main(weight: .regular, size: 14)
            label.numberOfLines = 3
            label.isUserInteractionEnabled = true
        }

        contentStackView = UIStackView().then { stackView in

            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(descriptionLabel)

            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 8
            stackView.distribution = .equalCentering

            contentView.addSubview(stackView) {
                $0.left.right.equalToSuperview()
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
    }

    private func clearUI() {
        applyTitledUI()
        titleLabel.text = ""
        descriptionLabel.text = ""
    }

    private func applyDescriptionUI() {
        contentStackView.spacing = 8
        contentStackView.distribution = .equalCentering
        contentStackView.addArrangedSubview(descriptionLabel)
    }

    private func applyTitledUI() {
        contentStackView.spacing = 0
        contentStackView.distribution = .fill
        descriptionLabel.removeFromSuperview()
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

extension BlenderInfoCollectionViewCell: BlenderObserver {

    func blenderDidReceiveResponse(for blenderMonth: BlenderMonth) {
        onMainThread {
            self.titleLabel.text = blenderMonth.value
            self.titleLabel.textColor = blenderMonth.textColor
            self.descriptionLabel.text = blenderMonth.seasonality
        }
    }
}
