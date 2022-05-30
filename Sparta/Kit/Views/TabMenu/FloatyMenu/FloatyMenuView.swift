//
//  FloatyMenuView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 11.02.2022.
//

import UIKit
import SpartaHelpers

class FloatyMenuView: UIView {

    // MARK: - Private properties

    private var _onChooseClosure: TypeClosure<TabMenuItem>?

    // MARK: - UI

    private var stackView: UIStackView!
    private(set) var items: [TabMenuItem] = []

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Public methods

    func onChoose(completion: @escaping TypeClosure<TabMenuItem>) {
        _onChooseClosure = completion
    }

    func apply(items: [TabMenuItem]) {
        self.items = items
        stackView.removeAllSubviews()

        items.forEach { item in
            let view = TabMenuItemView(item: item)
            view.onTap { [unowned self] tabView in
                guard let view = tabView as? TabMenuItemView else { return }

                self._onChooseClosure?(view.item)
            }
            stackView.addArrangedSubview(view)
            view.snp.makeConstraints {
                $0.height.equalTo(45)
            }
        }
    }

    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = .neutral85

        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.menuBorder.cgColor

        stackView = UIStackView().then { stackView in

            stackView.axis = .vertical
            stackView.spacing = 18
            stackView.distribution = .equalSpacing

            addSubview(stackView) {
                $0.left.right.equalToSuperview().inset(18)
                $0.top.bottom.equalToSuperview().inset(16)
            }
        }
    }
}
