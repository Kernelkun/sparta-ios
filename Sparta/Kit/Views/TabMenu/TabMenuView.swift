//
//  TabMenuView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.02.2022.
//

import UIKit
import NetworkingModels
import SpartaHelpers

protocol TabMenuViewDelegate: AnyObject {
    func tabMenuViewDidSelectTab(_ view: TabMenuView, oldTabItem: TabMenuItem, newTabItem: TabMenuItem)
    func tabMenuViewDidDoubleTapOnTab(_ view: TabMenuView, tabItem: TabMenuItem)
}

class TabMenuView: UIView {

    // MARK: - Public properties

    weak var delegate: TabMenuViewDelegate?

    var selectedTabIndex: Int = 0 {
        didSet { renderSubItems(oldIndex: oldValue, newIndex: selectedTabIndex) }
    }
    private(set) var items: [TabMenuItem] = []

    // MARK: - Private properties

    private var _tapClosure: TypeClosure<TabMenuItem>?

    // MARK: - UI

    private var stackView: UIStackView!

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Public methods

    func apply(items: [TabMenuItem], selectedTabIndex: Int) {
        self.items = items
        stackView.removeAllSubviews()

        items.forEach { item in
            let view = TabMenuItemView(item: item)

            view.onTap { [unowned self] tabView in
                guard let view = tabView as? TabMenuItemView,
                      let activeTabIndex = items.firstIndex(of: view.item) else { return }

                self.selectedTabIndex = activeTabIndex
            }

            view.onDoubleTap { [unowned self] item in
                delegate?.tabMenuViewDidDoubleTapOnTab(self, tabItem: item)
            }

            stackView.addArrangedSubview(view)
        }

        self.selectedTabIndex = selectedTabIndex
    }

    func onTap(completion: @escaping TypeClosure<TabMenuItem>) {
        _tapClosure = completion
    }

    func forceChangeItem(_ newTabItem: TabMenuItem) {
        guard let itemIndex = items.firstIndex(of: newTabItem) else { return }

        selectedTabIndex = itemIndex
    }

    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = .neutral85

        let topLineView = UIView().then { view in

            view.backgroundColor = .menuBorder

            addSubview(view) {
                $0.top.equalToSuperview()
                $0.left.right.equalToSuperview()
                $0.height.equalTo(CGFloat.separatorWidth)
            }
        }

        stackView = UIStackView().then { stackView in

            stackView.axis = .horizontal
            stackView.spacing = 0
            stackView.distribution = .fillEqually
            stackView.spacing = 8

            addSubview(stackView) {
                $0.left.right.equalToSuperview().inset(6)
                $0.bottom.equalToSuperview()
                $0.top.equalTo(topLineView.snp.bottom)
            }
        }
    }

    private func renderSubItems(oldIndex: Int, newIndex: Int) {
        for (index, view) in stackView.arrangedSubviews.enumerated() {
            guard let view = view as? TabMenuItemView else { return }

            let isActive = index == newIndex
            view.isActive = isActive
        }

        delegate?.tabMenuViewDidSelectTab(self, oldTabItem: items[oldIndex], newTabItem: items[newIndex])
    }
}
