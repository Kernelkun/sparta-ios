//
//  LiveCurveProfilesView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 17.05.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers

class ProfilesView<I: ListableItem>: UIView {

    // MARK: - Private properties

    private let constructor: ProfilesViewConstructor

    private var profiles: [I] = []
    private var selectedProfile: I?

    private var scrollContentView: UIView!
    private var elementsStackView: UIStackView!
    private var elementViews: [ProfileElementView<I>] = []

    private var _onChooseAdd: EmptyClosure?
    private var _onChooseProfileClosure: TypeClosure<I>?
    private var _onLongPressProfileClosure: TypeClosure<I>?

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

    func onLongPressProfile(completion: @escaping TypeClosure<I>) {
        _onLongPressProfileClosure = completion
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

        let scrollView = UIScrollView().then { scrollView in

            scrollView.alwaysBounceHorizontal = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            scrollView.scrollsToTop = false
            scrollView.automaticallyAdjustsScrollIndicatorInsets = false
            scrollView.contentInsetAdjustmentBehavior = .never
            scrollView.backgroundColor = .profileBackground
            scrollView.layer.cornerRadius = 9

            scrollContentView = UIView().then { view in

                view.backgroundColor = .clear

                scrollView.addSubview(view) {
                    $0.centerY.equalToSuperview()
                    $0.top.bottom.left.equalToSuperview().inset(2)
                    $0.right.lessThanOrEqualToSuperview()
                    $0.width.greaterThanOrEqualToSuperview().inset(2)
                }
            }

            scrollView.snp.makeConstraints {
                $0.height.equalTo(30)
            }
        }

        _ = UIStackView().then { stackView in

            stackView.axis = .horizontal
            stackView.distribution = .fill
            stackView.spacing = 10
            stackView.alignment = .fill

            stackView.addArrangedSubview(scrollView)

            if constructor.addButtonAvailability {
                stackView.addArrangedSubview(plusButton)
            }

            addSubview(stackView) {
                $0.left.right.equalToSuperview().inset(16)
                $0.centerY.equalToSuperview()
                $0.height.equalTo(30)
            }
        }
    }

    private func setupElementsViews() {
        scrollContentView.removeAllSubviews()

        elementsStackView = UIStackView().then { stackView in

            stackView.axis = .horizontal
            stackView.distribution = .fillProportionally
            stackView.spacing = 0
            stackView.alignment = .fill

            profiles.forEach { profile in
                let view = ProfileElementView(profile: profile)
                view.isActive = self.selectedProfile == profile

                view.onTap { [unowned self] view in
                    guard let view = view as? ProfileElementView<I> else { return }

                    self.selectedProfile = view.profile
                    self.updateElementsUI()
                    self._onChooseProfileClosure?(view.profile)
                }

                view.onLongPress { [unowned self] item in
                    guard profiles.count > 1 else { return }

                    self._onLongPressProfileClosure?(item)
                }

                stackView.addArrangedSubview(view)
                elementViews.append(view)
            }

            scrollContentView.addSubview(stackView) {
                $0.edges.equalToSuperview()
            }
        }

        updateElementsUI()
    }

    private func updateElementsUI() {
        elementViews.forEach { view in
            view.showLine()
            view.isActive = selectedProfile == view.profile

            if let index = elementViews.firstIndex(of: view) {
                let view = elementViews[index]

                if index != 0 && view.isActive {
                    let previousView = elementViews[index - 1]
                    previousView.hideLine()
                }

                if index == elementViews.count - 1 {
                    view.hideLine()
                }
            }
        }
    }
}
