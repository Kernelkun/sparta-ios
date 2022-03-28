//
//  MainSegmentedView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 30.11.2021.
//

import UIKit
import SpartaHelpers
import NetworkingModels

class MainSegmentedView<I: DisplayableItem & CaseIterable>: UIControl {

    // MARK: - Public properties

    var selectedIndex = 0 {
        didSet { updateUI(animated: true) }
    }

    // MARK: - Private properties

    private let items: [I]
    private var _onChooseClosure: TypeClosure<I>?
    private var mainStackView: UIStackView!
    private var selectionView: UIView!
    private var oldFrame: CGRect = .zero

    // MARK: - Initializers

    init(items: [I], selectedIndex: Int) {
        self.items = items
        super.init(frame: .zero)

        setupUI()
        self.selectedIndex = selectedIndex
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()

        if oldFrame != frame {
            updateUI(animated: false)
            oldFrame = frame
        }
    }

    // MARK: - Public methods

    func onSelect(completion: @escaping TypeClosure<I>) {
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
                    guard let view = view as? ItemView<I>,
                          let indexOfView = mainStackView.arrangedSubviews
                            .firstIndex(of: view) else { return }

                    self.selectedIndex = indexOfView
                    _onChooseClosure?(view.item)
                }
                stackView.addArrangedSubview(itemView)
            }

            addSubview(stackView) {
                $0.edges.equalToSuperview()
            }
        }

        selectionView = UIView().then { view in

            view.backgroundColor = .fip
            view.layer.cornerRadius = 7

            insertSubview(view, belowSubview: mainStackView)
        }

        onMainThread(delay: 0.2) {
            self.updateUI(animated: false)
        }
    }

    private func updateUI(animated: Bool) {
        guard selectedIndex < mainStackView.arrangedSubviews.count,
              let selectedItem = mainStackView.arrangedSubviews[selectedIndex] as? ItemView<I> else { return }

        selectLineToView(selectedItem, animated: animated)
    }

    private func selectLineToView(_ view: ItemView<I>, animated: Bool) {
        guard let frame = getFrameOfView(view) else { return }

        func makeSelectedFrame() {
            let insetedFrame = frame.inset(by: .init(top: 2, left: 1, bottom: 2, right: 1))
            self.selectionView.frame = insetedFrame
        }

        if animated {
            let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
                makeSelectedFrame()
            }

            animator.startAnimation()
        } else {
            makeSelectedFrame()
        }
    }

    private func getFrameOfView(_ alignView: ItemView<I>) -> CGRect? {
        mainStackView.arrangedSubviews.first { view in
            guard let view = view as? ItemView<I> else { return false }

            return alignView == view
        }?.frame
    }
}
