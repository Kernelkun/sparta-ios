//
//  ArbsMenuView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 26.10.2021.
//

import UIKit
import SpartaHelpers

class ArbsMenuView: UIView {

    // MARK: - Private properties

    private let items: [MenuItem]
    private var _onChooseClosure: TypeClosure<MenuItem>?
    private var selectionLineView: UIView!

    // MARK: - Initializers

    init(items: [MenuItem]) {
        self.items = items
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Public methods

    func onSelect(completion: @escaping TypeClosure<MenuItem>) {
        _onChooseClosure = completion
    }

    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = .neutral85

        _ = UIStackView().then { stackView in

            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.alignment = .fill

            items.forEach { item in
                let view = ArbsMenuItemView(item: item)
                view.onTap { [unowned self] view in
                    guard let view = view as? ArbsMenuItemView else { return }

                    _onChooseClosure?(view.item)
                    animateLineToView(view)
                }
                stackView.addArrangedSubview(view)
            }

            addSubview(stackView) {
                $0.width.equalTo(40)
                $0.left.right.equalToSuperview()
                $0.top.bottom.equalToSuperview().inset(9)
            }
        }

        setupSLineView()
    }

    private func setupSLineView() {
        selectionLineView = UIView().then { view in

            view.backgroundColor = .fip

            addSubview(view) {
                $0.height.equalTo(2)
                $0.left.equalToSuperview()
                $0.width.equalToSuperview().dividedBy(items.count)
                $0.bottom.equalToSuperview()
            }
        }
    }

    private func animateLineToView(_ view: UIView) {
        selectionLineView.snp.updateConstraints {
            $0.left.equalToSuperview().offset(view.frame.minX)
        }

        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
}

extension ArbsMenuView {
    enum MenuItem: String, CaseIterable {
        case table
        case dashboard
    }
}
