//
//  LiveCurveProfilesView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 17.05.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers

class ProfilesView<I: ListableItem>: UIView, UIScrollViewDelegate, SQReorderableStackViewDelegate {

    // MARK: - Private properties

    private let constructor: ProfilesViewConstructor

    private var profiles: [I] = []
    private var selectedProfile: I?

    private var scrollView: UIScrollView!
    private var scrollContentView: UIView!
    private var elementsStackView: UIStackView!

    private var _onChooseAdd: EmptyClosure?
    private var _onChooseProfileClosure: TypeClosure<I>?
    private var _onRemoveProfileClosure: TypeClosure<I>?
    private var _onReorderProfilesClosure: TypeClosure<[I]>?

    // MARK: - Initializers

    init(constructor: ProfilesViewConstructor) {
        self.constructor = constructor

        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("ProfilesView")
    }

    // MARK: - Public methods

    func apply(_ profiles: [I], selectedProfile: I?) {
        self.profiles = profiles
        self.selectedProfile = selectedProfile

        setupElementsViews()
    }

    func onChooseAdd(completion: @escaping EmptyClosure) {
        _onChooseAdd = completion
    }

    func onChooseProfile(completion: @escaping TypeClosure<I>) {
        _onChooseProfileClosure = completion
    }

    func onRemoveProfile(completion: @escaping TypeClosure<I>) {
        _onRemoveProfileClosure = completion
    }

    func onReorderProfiles(completion: @escaping TypeClosure<[I]>) {
        _onReorderProfilesClosure = completion
    }

    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = UIGridViewConstants.mainBackgroundColor

        // main scroll view

        setupMainViews()
    }

    private func setupMainViews() {

        let plusButton = TappableButton(type: .custom).then { button in

            button.setImage(UIImage(named: "ic_plus"), for: .normal)
            button.tintColor = .primaryText
            button.backgroundColor = .profileBackground
            button.layer.cornerRadius = 6

            button.onTap { [unowned self] _ in
                self._onChooseAdd?()
            }

            button.snp.makeConstraints {
                $0.size.equalTo(CGSize(width: 33, height: 30))
            }
        }

        let scrollExternalView = UIView().then { view in

            view.backgroundColor = .clear
            view.clipsToBounds = true

            view.snp.makeConstraints {
                $0.height.equalTo(40)
            }
        }

        scrollView = UIScrollView().then { scrollView in

            scrollView.alwaysBounceHorizontal = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            scrollView.scrollsToTop = false
            scrollView.automaticallyAdjustsScrollIndicatorInsets = false
            scrollView.contentInsetAdjustmentBehavior = .never
            scrollView.clipsToBounds = false

            scrollContentView = UIView().then { view in

                view.backgroundColor = .clear
                view.clipsToBounds = false
                view.backgroundColor = .profileBackground
                view.layer.cornerRadius = 9

                scrollView.addSubview(view) {
                    $0.centerY.equalToSuperview()
                    $0.top.bottom.left.equalToSuperview().inset(2)
                    $0.right.lessThanOrEqualToSuperview().inset(constructor.isEditable ? 8 : 0)
                    $0.width.greaterThanOrEqualToSuperview().inset(2)
                }
            }

            scrollExternalView.addSubview(scrollView) {
                $0.left.bottom.right.equalToSuperview()
                $0.height.equalTo(30)
            }
        }

        _ = UIStackView().then { stackView in

            stackView.axis = .horizontal
            stackView.distribution = .fill
            stackView.spacing = 10
            stackView.alignment = .bottom

            stackView.addArrangedSubview(scrollExternalView)

            if constructor.addButtonAvailability {
                stackView.addArrangedSubview(plusButton)
            }

            addSubview(stackView) {
                $0.left.right.equalToSuperview().inset(16)
                $0.centerY.equalToSuperview()
            }
        }
    }

    private func setupElementsViews() {
        scrollContentView.removeAllSubviews()

        elementsStackView = SQReorderableStackView().then { stackView in

            stackView.axis = .horizontal
            stackView.distribution = .fillProportionally
            stackView.spacing = 0
            stackView.alignment = .fill
            stackView.reorderingEnabled = constructor.isEditable
            stackView.reorderDelegate = self

            profiles.forEach { profile in
                let view = ProfileElementView(profile: profile)
                view.isActive = self.selectedProfile == profile

                view.onTap { [unowned self] view in
                    guard let view = view as? ProfileElementView<I> else { return }

                    self.scrollContentView.bringSubviewToFront(view)
                    self.selectedProfile = view.profile
                    self.updateElementsUI()
                    self._onChooseProfileClosure?(view.profile)
                }

                view.onRemove { [unowned self] item in
                    guard profiles.count > 1 else { return }

                    self._onRemoveProfileClosure?(item)
                }

                stackView.addArrangedSubview(view)
            }

            scrollContentView.addSubview(stackView) {
                $0.edges.equalToSuperview()
            }
        }

        updateElementsUI()
    }

    private func updateElementsUI() {
        for (index, view) in elementsStackView.arrangedSubviews.enumerated() {
            guard let view = view as? ProfileElementView<I> else { return }

            let isSelected = selectedProfile == view.profile

            view.showLine()
            view.isActive = isSelected
            view.isVisibleDeleteButton = isSelected && constructor.isEditable && profiles.count > 1

            if index != 0 && view.isActive,
               let previousView = elementsStackView.arrangedSubviews[index - 1] as? ProfileElementView<I> {

                previousView.hideLine()
            }

            if index == elementsStackView.arrangedSubviews.count - 1 {
                view.hideLine()
            }
        }

        // scroll to visible view

        if let views = elementsStackView.arrangedSubviews as? [ProfileElementView<I>],
           let selectedView = views.first(where: { $0.isActive }) {

            onMainThread(delay: 0.1) { [unowned self] in
                scrollTo(view: selectedView)
            }
        }
    }

    private func scrollTo(view: UIView) {
        let scrollWidth = scrollView.frame.width
        let scrollHeight = scrollView.frame.height
        let desiredXCoor = view.frame.origin.x - ((scrollWidth / 2) - (view.frame.width + 6 / 2) )
        let rect = CGRect(x: desiredXCoor, y: 0, width: scrollWidth, height: scrollHeight)

        scrollView.scrollRectToVisible(rect, animated: true)
    }

    // MARK: - SQReorderableStackViewDelegate

    func stackView(_ stackView: SQReorderableStackView, canReorderSubview subview: UIView, atIndex index: Int) -> Bool {
        true
    }

    func stackView(_ stackView: SQReorderableStackView, shouldAllowSubview subview: UIView, toMoveToIndex index: Int) -> Bool {
        true
    }

    func stackView(_ stackView: SQReorderableStackView, didDragToReorderInForwardDirection forward: Bool, maxPoint: CGPoint, minPoint: CGPoint) {
        let scrollWidth = scrollView.frame.width
        let visibleMaxPosition = scrollWidth + scrollView.contentOffset.x
        let visibleMaxRestPosition = (scrollView.contentSize.width - visibleMaxPosition)
        let visibleMinPosition = scrollView.contentSize.width - (scrollWidth + visibleMaxRestPosition)

        let minPosition = visibleMinPosition + 50
        let maxPosition = visibleMaxPosition - 50

        if forward && minPoint.x < minPosition && scrollView.contentOffset.x > 0 {
            let finishPosition = scrollView.contentOffset.x - 100

            if finishPosition > 0 {
                scrollView.setContentOffset(.init(x: finishPosition, y: 0), animated: true)
            } else {
                scrollView.setContentOffset(.init(x: 0, y: 0), animated: true)
            }
        } else if !forward && maxPoint.x > maxPosition && (scrollView.contentOffset.x + scrollWidth) < scrollView.contentSize.width {
            let finishPosition = scrollView.contentOffset.x + 100

            if (finishPosition + scrollWidth) < scrollView.contentSize.width {
                scrollView.setContentOffset(.init(x: finishPosition, y: 0), animated: true)
            } else {
                scrollView.setContentOffset(.init(x: scrollView.contentSize.width - scrollWidth, y: 0), animated: true)
            }
        }
    }

    func stackViewDidReorderArrangedSubviews(_ stackView: SQReorderableStackView) {
        updateElementsUI()

        let profiles = stackView.arrangedSubviews.compactMap { view -> I? in
            guard let view = view as? ProfileElementView<I> else { return nil }
            return view.profile
        }
        self.profiles = profiles
        _onReorderProfilesClosure?(profiles)
    }
}
