//
//  ArbVHeaderView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 01.12.2021.
//

import UIKit
import SpartaHelpers

protocol ArbVHeaderViewDelegate: AnyObject {
    func arbVHeaderViewDidChangeSegmentedViewValue(_ view: ArbVHeaderView, item: MainSegmentedView.MenuItem)
}

class ArbVHeaderView: UIView {

    // MARK: - Public properties

    weak var delegate: ArbVHeaderViewDelegate?

    private(set) var topRightContentView: UIView!
    private(set) var bottomContentView: UIView!

    // MARK: - Private properties

    private let configurator: Configurator
    private var topContentView: UIView!
    private var mainStackView: UIStackView!
    private var segmetedView: MainSegmentedView!

    // MARK: - Initializers

    init(configurator: Configurator) {
        self.configurator = configurator
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Public methods

    func applyState(isMinimized: Bool) {
        bottomContentView.isHidden = isMinimized
    }

    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = .neutral75

        topContentView = UIView().then { view in

            view.backgroundColor = .clear

            view.snp.makeConstraints {
                $0.height.equalTo(35)
            }
        }

        bottomContentView = UIView().then { view in

            view.backgroundColor = UIColor.black.withAlphaComponent(0.2)

            view.snp.makeConstraints {
                $0.height.equalTo(35)
            }
        }

        mainStackView = UIStackView().then { stackView in

            stackView.spacing = 10
            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.distribution = .equalSpacing

            stackView.addArrangedSubview(topContentView)
            stackView.addArrangedSubview(bottomContentView)

            addSubview(stackView) {
                $0.top.equalToSuperview().offset(10)
                $0.left.right.equalToSuperview()
            }
        }

        segmetedView = MainSegmentedView(
            items: MainSegmentedView.MenuItem.allCases,
            selectedIndex: configurator.selectedIndexOfMenuItem
        ).then { view in

            view.onSelect { [unowned self] item in
                self.delegate?.arbVHeaderViewDidChangeSegmentedViewValue(self, item: item)
            }

            topContentView.addSubview(view) {
                $0.height.equalTo(32)
                $0.left.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
        }

        let playgroundButton = ArbsVPlaygroundButton().then { button in

            topContentView.addSubview(button) {
                $0.centerY.right.equalToSuperview()
                $0.size.equalTo(35)
            }
        }

        topRightContentView = UIView().then { view in

            view.backgroundColor = .red

            topContentView.addSubview(view) {
                $0.left.equalTo(segmetedView.snp.right)
                $0.right.equalTo(playgroundButton.snp.left)
                $0.height.equalTo(32)
                $0.centerY.equalToSuperview()
            }
        }

        /*let destinationSelector = UISelector<PickerIdValued<Date>>(uiConfigurator: .visualisationStyle).then { view in

//            view.onChooseValue { [unowned self] value in
//                self.viewModel.selectedFreightPort = value
//                self.viewModel.reloadMainOptions()
//            }

            topContentView.addSubview(view) {
                $0.size.equalTo(CGSize(width: 228, height: 32))
                $0.centerY.equalToSuperview()
                $0.left.equalTo(segmetedView.snp.right).offset(15)
            }
        }*/
    }
}

extension ArbVHeaderView {

    struct Configurator {
        let selectedIndexOfMenuItem: Int
    }
}
