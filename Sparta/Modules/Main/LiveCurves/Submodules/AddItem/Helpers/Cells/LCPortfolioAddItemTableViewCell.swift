//
//  LCPortfolioAddItemTableViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 14.05.2021.
//

import UIKit
import SpartaHelpers

class LCPortfolioAddItemTableViewCell: UITableViewCell {

    // MARK: - UI

    private var titleLabel: UILabel!

    // MARK: - Private properties

    private var _onChooseClosure: TypeClosure<IndexPath>?
    private var indexPath: IndexPath!

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("LCPortfolioAddItemTableViewCell")
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()

        clearUI()
    }

    // MARK: - Public methods

    func apply(item: LCPortfolioAddItemViewModel.Item, for indexPath: IndexPath) {
        self.indexPath = indexPath

        titleLabel.text = item.title
        titleLabel.textColor = item.isActive ? .primaryText : UIColor.primaryText.withAlphaComponent(0.47)
    }

    func onChoose(completion: @escaping TypeClosure<IndexPath>) {
        _onChooseClosure = completion
    }

    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = .clear
        selectedBackgroundView = UIView().then { $0.backgroundColor = .mainBackground }
        tintColor = .controlTintActive
        selectionStyle = .none

        titleLabel = UILabel().then { label in

            label.textAlignment = .left
            label.textColor = .primaryText
            label.font = .main(weight: .regular, size: 17)
            label.numberOfLines = 1

            contentView.addSubview(label) {
                $0.centerY.equalToSuperview()
                $0.left.right.equalToSuperview().offset(16)
            }
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapClosure))
        contentView.addGestureRecognizer(tapGesture)
    }

    private func clearUI() {
        indexPath = nil
    }

    // MARK: - Events

    @objc
    private func onTapClosure() {
        guard let indexPath = indexPath else { return }

        _onChooseClosure?(indexPath)
    }
}
