//
//  FloatyMenuView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 11.02.2022.
//

import UIKit

class FloatyMenuView: UIView {

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

    func apply(items: [TabMenuItem]) {
        self.items = items
        stackView.removeAllSubviews()

        items.forEach { item in
            let view = TabMenuItemView(item: item)
            view.onTap { [unowned self] tabView in
                guard let view = tabView as? TabMenuItemView,
                      let activeTabIndex = items.firstIndex(of: view.item) else { return }

//                self.selectedTabIndex = activeTabIndex
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
                $0.left.right.equalToSuperview().inset(16)
                $0.top.bottom.equalToSuperview().inset(16)
            }
        }
    }
}
