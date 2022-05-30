//
//  ACDeliveryDateTableLightView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 29.04.2022.
//

import UIKit
import NetworkingModels

class ACDeliveryDateTableLightView: UIView {

    // MARK: - Public properties

    var state: State = .inactive {
        didSet { updateUI() }
    }

    // MARK: - Private properties

    private var titleLabel: UILabel!
    private var detailLabel: UILabel!
    private var contentView: UIView!

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Private methods

    private func setupUI() {
        contentView = UIView().then { view in

            view.layer.cornerRadius = 4

            addSubview(view) {
                $0.edges.equalToSuperview()
            }
        }

        let lineView = UIView().then { view in

            view.backgroundColor = .primaryText

            contentView.addSubview(view) {
                $0.height.equalTo(0.5)
                $0.left.right.equalToSuperview()
                $0.bottom.equalToSuperview().inset(18.5)
            }
        }

        titleLabel = UILabel().then { label in

            label.textAlignment = .center
            label.textColor = .primaryText
            label.font = .main(weight: .medium, size: 16)
            label.numberOfLines = 0

            contentView.addSubview(label) {
                $0.left.top.right.equalToSuperview()
                $0.bottom.equalTo(lineView.snp.top)
            }
        }

        detailLabel = UILabel().then { label in

            label.textAlignment = .center
            label.textColor = .primaryText
            label.font = .main(weight: .medium, size: 10)
            label.numberOfLines = 0
            label.text = "mr".uppercased()

            contentView.addSubview(label) {
                $0.top.equalTo(lineView.snp.bottom)
                $0.bottom.equalToSuperview()
                $0.centerX.equalToSuperview()
            }
        }
    }

    private func updateUI() {
        switch state {
        case .inactive:
            titleLabel.text = nil
            contentView.backgroundColor = .black

        case .active(let color, let text):
            titleLabel.text = text
            contentView.backgroundColor = color
        }
    }
}

extension ACDeliveryDateTableLightView {
    enum State {
        case inactive
        case active(color: UIColor, text: String)
    }
}
