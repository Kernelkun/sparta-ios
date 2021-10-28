//
//  APPCLightView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.10.2021.
//

import UIKit

class APPCLightView: UIView {

    // MARK: - Public properties

    var state: State = .inactive {
        didSet { updateUI() }
    }

    // MARK: - Private properties

    private var titleLabel: UILabel!
    private var contentView: UIView!

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setupUI() {
        contentView = UIView().then { view in

            view.layer.cornerRadius = 4
            view.backgroundColor = .numberGreen

            addSubview(view) {
                $0.edges.equalToSuperview()
            }
        }

        titleLabel = UILabel().then { label in

            label.text = "7.87"
            label.textAlignment = .center
            label.textColor = .primaryText
            label.font = .main(weight: .medium, size: 16)
            label.numberOfLines = 0

            contentView.addSubview(label) {
                $0.edges.equalToSuperview()
            }
        }
    }

    private func updateUI() {

    }
}

extension APPCLightView {
    enum State {
        case inactive
        case active(color: UIColor, text: String)
    }
}
