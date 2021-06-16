//
//  LiveCurveProfilesView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 17.05.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers

class ProfilesView<I: ListableItem>: UIView, UIScrollViewDelegate {

    // MARK: - Private properties

    private let constructor: ProfilesViewConstructor

    private var profiles: [I] = []
    private var selectedProfile: I?

    private var scrollView: UIScrollView!
    private var scrollContentView: UIView!
    private var elementsStackView: UIStackView!
    private var elementViews: [ProfileElementView<I>] = []
    private var activeElementView: ProfileElementView<I>?

    private var _onChooseAdd: EmptyClosure?
    private var _onChooseProfileClosure: TypeClosure<I>?
    private var _onRemoveProfileClosure: TypeClosure<I>?

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
            let isSelected = selectedProfile == view.profile

            view.showLine()
            view.isActive = isSelected
            view.isVisibleDeleteButton = isSelected && constructor.isEditable && profiles.count > 1

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

        // scroll to visible view

        if let selectedView = elementViews.first(where: { $0.isActive }) {
            onMainThread(delay: 0.1) { [unowned self] in
                scrollTo(view: selectedView)
            }
        }
    }

    private func scrollTo(view: UIView) {
        let scrollWidth = scrollView.frame.width
        let scrollHeight = scrollView.frame.height
        let desiredXCoor = view.frame.origin.x - ((scrollWidth / 2) - (view.frame.width / 2) )
        let rect = CGRect(x: desiredXCoor, y: 0, width: scrollWidth, height: scrollHeight)

        scrollView.scrollRectToVisible(rect, animated: true)
    }
}
