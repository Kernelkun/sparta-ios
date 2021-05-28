//
//  ProfileElementView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 17.05.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers

class ProfileElementView<I: ListableItem>: TappableView {

    // MARK: - Public properties

    var isActive: Bool {
        didSet {
            updateUI()
        }
    }

    let profile: I

    // MARK: - Private properties

    private var selectedView: UIView!
    private var titleLabel: UIView!
    private var lineView: UIView!

    // MARK: - Initializers

    init(profile: I) {
        self.profile = profile
        isActive = false

        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("ProfileElementView")
    }

    // MARK: - Public methods

    func showLine() {
        lineView.isHidden = false
    }

    func hideLine() {
        lineView.isHidden = true
    }

    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = .clear

        selectedView = UIView().then { view in

            view.backgroundColor = .profileActiveBackground
            view.alpha = 1
            view.layer.cornerRadius = 7

            addSubview(view) {
                $0.edges.equalToSuperview()
            }
        }

        titleLabel = UILabel().then { label in

            label.font = .main(weight: .semibold, size: 13)
            label.textAlignment = .center
            label.textColor = .primaryText
            label.text = profile.title.capitalizedFirst

            addSubview(label) {
                $0.left.right.equalToSuperview().inset(16)
                $0.centerY.equalToSuperview()
            }
        }

        lineView = UIView().then { view in

            view.backgroundColor = .profileActiveBackground
            view.layer.cornerRadius = 1

            addSubview(view) {
                $0.right.equalToSuperview()
                $0.centerY.equalToSuperview()
                $0.size.equalTo(CGSize(width: 1, height: 15))
            }
        }
    }

    private func updateUI() {
        selectedView.alpha = isActive ? 1 : 0
        lineView.alpha = isActive ? 0 : 1
    }
}
