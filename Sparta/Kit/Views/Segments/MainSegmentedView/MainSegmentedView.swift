//
//  MainSegmentedView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 30.11.2021.
//

import UIKit
import SpartaHelpers

class MainSegmentedView: UIControl {

    // MARK: - Private properties

    private let items: [MenuItem]
    private var _onChooseClosure: TypeClosure<MenuItem>?

    private var mainStackView: UIStackView!
    private var selectionView: UIView!

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
        backgroundColor = .neutral70
        layer.cornerRadius = 9

        mainStackView = UIStackView().then { stackView in

            stackView.axis = .horizontal
            stackView.distribution = .fillProportionally
            stackView.alignment = .fill

            items.forEach { item in
                let itemView = ItemView(item: item)
                itemView.onTap { [unowned self] view in
                    guard let view = view as? ItemView else { return }

                    _onChooseClosure?(view.item)
                    animateLineToView(view)
                }
                stackView.addArrangedSubview(itemView)
            }

            addSubview(stackView) {
                $0.edges.equalToSuperview()
            }
        }

        setupSView()
    }

    private func setupSView() {
        selectionView = UIView().then { view in

            view.backgroundColor = .fip
            view.layer.cornerRadius = 7

            insertSubview(view, belowSubview: mainStackView)
        }

        animateLineToView(mainStackView.arrangedSubviews.first as! ItemView) //swiftlint:disable:this force_cast
    }

    private func animateLineToView(_ view: ItemView) {
        guard let frame = getFrameOfView(view) else { return }

        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {

            let insetedFrame = frame.inset(by: .init(top: 2, left: 1, bottom: 2, right: 1))

            self.selectionView.frame = insetedFrame
        }

        animator.startAnimation()
    }

    private func getFrameOfView(_ alignView: ItemView) -> CGRect? {
        mainStackView.arrangedSubviews.first { view in
            guard let view = view as? ItemView else { return false }

            return alignView == view
        }?.frame
    }
}

extension MainSegmentedView {
    enum MenuItem: String, CaseIterable {
        case pricingCenter = "Pricing center"
        case arbsComparation = "ARBs comparation"
    }
}
