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

    var isVisibleDeleteButton: Bool {
        didSet {
            updateUI()
        }
    }

    let profile: I

    // MARK: - Private properties

    private var selectedView: UIView!
    private var titleLabel: UIView!
    private var lineView: UIView!
    private var deleteButton: TappableButton!

    private var _onRemoveClosure: TypeClosure<I>?

    // MARK: - Initializers

    init(profile: I) {
        self.profile = profile
        isActive = false
        isVisibleDeleteButton = false

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

    func onRemove(completion: @escaping TypeClosure<I>) {
        _onRemoveClosure = completion
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

        deleteButton = TappableButton(type: .custom).then { button in

            button.clickableInset = -10
            button.setBackgroundImage(UIImage(named: "ic_remove"), for: .normal)
            button.onTap { [unowned self] _ in
                self._onRemoveClosure?(self.profile)
            }

            addSubview(button) {
                let sideSize = 21.5
                $0.top.equalToSuperview().offset(-(sideSize / 2.6))
                $0.right.equalToSuperview().offset(sideSize / 2.6)
                $0.size.equalTo(sideSize)
            }
        }

        updateUI()
    }

    private func updateUI() {
        selectedView.alpha = isActive ? 1 : 0
        lineView.alpha = isActive ? 0 : 1
        deleteButton.alpha = isVisibleDeleteButton ? 1 : 0
    }
}
