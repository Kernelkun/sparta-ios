//
//  CardContentView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 05.02.2022.
//

import UIKit

enum CardViewState {
    case expanded
    case collapsed

    var change: CardViewState {
        switch self {
        case .expanded: return .collapsed
        case .collapsed: return .expanded
        }
    }
}

protocol CardViewDelegate: AnyObject {
    func cardViewDidChangeState(_ view: CardViewInterface, state: CardViewState)
}

protocol CardViewInterface: UIView {
    var state: CardViewState { get }
    var contentView: UIView { get }
//    var bottomOffset: CGFloat { get }
    var delegate: CardViewDelegate? { get set }

    func expandedFrame(superviewFrame: CGRect) -> CGRect
    func collapsedFrame(superviewFrame: CGRect) -> CGRect
    func changeState(_ newState: CardViewState)
}

class CardContentView: UIView, CardViewInterface {

    // MARK: - Public properties

    weak var delegate: CardViewDelegate?

    private(set) var collapseBottomOffset: CGFloat = 175
    private(set) var expandTopOffset: CGFloat = 100

    private(set) var contentView: UIView
    private(set) var state: CardViewState = .collapsed

    // MARK: - Variables public

    private lazy var animator: UIViewPropertyAnimator = {
        UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut)
    }()
    private lazy var panRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        return recognizer
    }()
    private var animationProgress: CGFloat = 0

    // MARK: - Initializers

    init() {
        contentView = UIView()
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func changeState(_ newState: CardViewState) {
        switch self.state {
        case .expanded:
            expand()

        case .collapsed:
            collapse()
        }
    }

    func expandedFrame(superviewFrame: CGRect) -> CGRect {
        CGRect(
            x: 0,
            y: expandTopOffset,
            width: superviewFrame.width,
            height: superviewFrame.height - expandTopOffset
        )
    }

    func collapsedFrame(superviewFrame: CGRect) -> CGRect {
        CGRect(
            x: 0,
            y: superviewFrame.height - collapseBottomOffset,
            width: superviewFrame.width,
            height: superviewFrame.height - expandTopOffset
        )
    }

    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = .red
        addGestureRecognizer(panRecognizer)

        layer.cornerRadius = 15
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.masksToBounds = true

        contentView.do { view in

            addSubview(view) {
                $0.edges.equalToSuperview()
            }
        }
    }

    private func expand() {
        animator.addAnimations {
            guard let superview = self.superview else { return }

            self.frame = self.expandedFrame(superviewFrame: superview.frame)
        }

        animator.addCompletion { position in
            switch position {
            case .end:
                self.state = self.state.change
                self.delegate?.cardViewDidChangeState(self, state: self.state)

            default:
                break
            }
        }

        animator.startAnimation()
    }

    private func collapse() {
        animator.addAnimations {
            guard let superview = self.superview else { return }

            self.frame = self.collapsedFrame(superviewFrame: superview.frame)
        }

        animator.addCompletion { position in
            switch position {
            case .end:
                self.state = self.state.change
                self.delegate?.cardViewDidChangeState(self, state: self.state)

            default:
                break
            }
        }

        animator.startAnimation()
    }

    @objc
    private func testContentViewTap() {
        switch self.state {
        case .expanded:
            collapse()

        case .collapsed:
            expand()
        }
    }

    @objc
    func popupViewPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            testContentViewTap()
            animator.pauseAnimation()
            animationProgress = animator.fractionComplete

        case .changed:
            let translation = recognizer.translation(in: self)
            var fraction = translation.y / frame.height
            if state == .expanded { fraction *= -1 }
            if animator.isReversed { fraction *= -1 }
            animator.fractionComplete = fraction + animationProgress

        case .ended:
            let velocity = recognizer.velocity(in: self)

//            if velocity.y >= 0 || animator.fractionComplete < 0.30 {
//                animator.isReversed = false
//            }

            print("Velocity: \(velocity.y)")

            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)

        default:
            break
        }
    }
}
