//
//  CollapsableView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 06.10.2021.
//

import UIKit
import SpartaHelpers

class CollapsableView: TappableView {

    // MARK: - Private properties

    private var contentView: UIView!
    private var stackView: UIStackView!

    private var constructor: Constructor

    // MARK: - Initializers

    init(constructor: Constructor) {
        self.constructor = constructor
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Public methods

    func switchUI(animated: Bool) {
        constructor.isCollapsed.toggle()

        func animateIfNeeded(completion: @escaping EmptyClosure) {
            guard animated else {
                completion()
                return
            }

            animate {
                completion()
            }
        }

        animateIfNeeded {
            self.updateViewsState()
        }
    }

    func switchToState(isCollapsed: Bool, animated: Bool) {
        constructor.isCollapsed = isCollapsed

        func animateIfNeeded(completion: @escaping EmptyClosure) {
            guard animated else {
                completion()
                return
            }

            animate {
                completion()
            }
        }

        animateIfNeeded {
            self.updateViewsState()
        }
    }

    func apply(constructor: Constructor) {
        self.constructor = constructor
        updateViewsState()
        updateStackViewSubviews()
    }

    // MARK: - Private methods

    private func setupUI() {
        clipsToBounds = true

        contentView = UIView().then { view in
            view.backgroundColor = .clear

            addSubview(view, makeConstraints: {
                $0.edges.equalToSuperview()
            })
        }

        stackView = UIStackView().then { stackView in

            stackView.alignment = .fill
            stackView.distribution = .equalSpacing
            stackView.spacing = 0
            stackView.axis = .vertical

            contentView.addSubview(stackView, makeConstraints: {
                $0.edges.equalToSuperview()
            })
        }

        updateViewsState()
        updateStackViewSubviews()

        // events

        onTap { [unowned self] _ in
            guard constructor.isUserInteractable else { return }

            self.animate {
                self.switchUI(animated: true)
            }
        }
    }

    private func updateViewsState() {
        constructor.minView?.isHidden = !constructor.isCollapsed
        constructor.maxView?.isHidden = constructor.isCollapsed
    }

    private func updateStackViewSubviews() {
        stackView.removeAllArrangedSubviews()

        if let minView = constructor.minView {
            stackView.addArrangedSubview(minView)
        }

        if let maxView = constructor.maxView {
            stackView.addArrangedSubview(maxView)
        }
    }

    private func animate(animations: @escaping EmptyClosure, completion: EmptyClosure? = nil) {
        UIView.animate(withDuration: 0.3) {
            animations()
        }
    }
}

extension CollapsableView {
    struct Constructor {
        let isUserInteractable: Bool
        var isCollapsed: Bool
        let minView: UIView?
        let maxView: UIView?
    }
}
