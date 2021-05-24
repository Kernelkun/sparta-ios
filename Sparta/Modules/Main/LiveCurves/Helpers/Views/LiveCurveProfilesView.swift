//
//  LiveCurveProfilesView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 17.05.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers

class LiveCurveProfilesView: UIView {

    // MARK: - Private properties

    private var profiles: [LiveCurveProfileCategory] = []
    private var selectedProfile: LiveCurveProfileCategory?

    private var scrollContentView: UIView!
    private var elementsStackView: UIStackView!
    private var elementViews: [LiveCurveProfileElementView] = []

    private var _onChooseAdd: EmptyClosure?
    private var _onChooseProfileClosure: TypeClosure<LiveCurveProfileCategory>?

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("LiveCurveProfilesView")
    }

    // MARK: - Public methods

    func apply(_ profiles: [LiveCurveProfileCategory], selectedProfile: LiveCurveProfileCategory?) {
        self.profiles = profiles
        self.selectedProfile = selectedProfile

        setupElementsViews()
    }

    func onChooseAdd(completion: @escaping EmptyClosure) {
        _onChooseAdd = completion
    }

    func onChooseProfile(completion: @escaping TypeClosure<LiveCurveProfileCategory>) {
        _onChooseProfileClosure = completion
    }

    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = UIGridViewConstants.mainBackgroundColor

        // main scroll view

        setupMainViews()
    }

    private func setupMainViews() {

        let plusButton = TappableButton(type: .custom).then { button in

            button.setImage(UIImage(named: "ic_plus")?.withTintColor(.primaryText), for: .normal)
            button.backgroundColor = .profileBackground
            button.layer.cornerRadius = 6

            button.onTap { [unowned self] _ in
                self._onChooseAdd?()
            }

            addSubview(button) {
                $0.right.equalToSuperview().inset(11)
                $0.centerY.equalToSuperview()
                $0.size.equalTo(CGSize(width: 33, height: 30))
            }
        }

        _ = UIScrollView().then { scrollView in

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
                    $0.width.greaterThanOrEqualToSuperview()
                }
            }

            addSubview(scrollView) {
                $0.left.equalToSuperview().offset(18)
                $0.right.equalTo(plusButton.snp.left).offset(-10)
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
                let view = LiveCurveProfileElementView(profile: profile)
                view.isActive = self.selectedProfile == profile

                view.onTap { [unowned self] view in
                    guard let view = view as? LiveCurveProfileElementView else { return }

                    self.selectedProfile = view.profile
                    self.updateElementsUI()
                      self._onChooseProfileClosure?(view.profile)
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
