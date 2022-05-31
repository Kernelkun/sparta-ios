//
//  AVBarController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.12.2021.
//

import UIKit

typealias StateBarObserver = (AVBarController.State) -> Void

private struct ScrollableObservables {
    let contentOffset: Observable<CGPoint>
    let contentSize: Observable<CGSize>
    let panGestureState: Observable<UIGestureRecognizer.State>
}

class AVBarController {

    // MARK: - Private properties

    private let scrollabe: Scrollable
    private let observables: ScrollableObservables
    private let stateBarObserver: StateBarObserver

    private var statesConfigurator: StatesConfigurator?

    // MARK: - Initializers

    init(scrollabe: Scrollable, stateBarObserver: @escaping StateBarObserver) {
        self.scrollabe = scrollabe
        self.stateBarObserver = stateBarObserver

        self.observables = ScrollableObservables(
            contentOffset: scrollabe.contentOffsetObservable,
            contentSize: scrollabe.contentSizeObservable,
            panGestureState: scrollabe.panGestureStateObservable
        )
    }

    // MARK: - Public methods

    func setStatesConfigurator(_ statesConfigurator: StatesConfigurator) {
        self.statesConfigurator = statesConfigurator
        setupScrollableObserving()

        var maxScrollAmount: CGFloat {
            let expandedHeight: CGFloat = statesConfigurator.expandPosition.height
            let collapsedHeight: CGFloat = statesConfigurator.collapsedPosition.height
            return expandedHeight - collapsedHeight
        }

        self.scrollabe.contentInset = UIEdgeInsets(top: maxScrollAmount, left: 0, bottom: 0, right: 0)
        self.scrollabe.updateContentOffset(.init(x: 0, y: -maxScrollAmount), animated: false)
    }

    // MARK: - Private methods

    private func setupScrollableObserving() {
        guard let statesConfigurator = statesConfigurator else { return }

        // Content offset observing.
        var previousContentOffset: CGPoint = .zero
        observables.contentOffset.observer = { [weak self] contentOffset in
            guard previousContentOffset != contentOffset,
                  let position = statesConfigurator.position(for: contentOffset.y) else { return }

            let direction: Direction

            if contentOffset.y > previousContentOffset.y {
                direction = .down
            } else {
                direction = .up
            }

            self?.stateBarObserver(.init(
                direction: direction,
                contentOffset: contentOffset,
                position: position,
                isCollapsed: position == statesConfigurator.collapsedPosition
            ))

            previousContentOffset = contentOffset
        }

        // Content size observing.
        var previousContentSize: CGSize?
        observables.contentSize.observer = { [weak self] contentSize in
            guard previousContentSize != contentSize else { return }
        }

        // Pan gesture state observing.
        observables.panGestureState.observer = { [weak self] state in
        }
    }
}

extension AVBarController {

    enum Direction {
        case up // swiftlint:disable:this identifier_name
        case down
    }

    struct State {
        let direction: Direction
        let contentOffset: CGPoint
        let position: Position
        let isCollapsed: Bool
    }

    struct Position: Equatable {
        let visibleRange: ClosedRange<CGFloat>
        let height: CGFloat

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.visibleRange == rhs.visibleRange
                && lhs.height == rhs.height
        }
    }

    struct StatesConfigurator {
        let expandPosition: Position
        let collapsedPosition: Position

        func position(for value: CGFloat) -> Position? {
            if expandPosition.visibleRange.contains(value) {
                return expandPosition
            } else if collapsedPosition.visibleRange.contains(value) {
                return collapsedPosition
            } else {
                return nil
            }
        }
    }
}
