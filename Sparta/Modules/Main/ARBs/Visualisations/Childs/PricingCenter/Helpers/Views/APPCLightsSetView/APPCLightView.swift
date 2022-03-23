//
//  APPCLightView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.10.2021.
//

import UIKit
import NetworkingModels

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

        titleLabel = UILabel().then { label in

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

extension APPCLightView {
    enum State {
        case inactive
        case active(color: UIColor, text: String)
    }
}
