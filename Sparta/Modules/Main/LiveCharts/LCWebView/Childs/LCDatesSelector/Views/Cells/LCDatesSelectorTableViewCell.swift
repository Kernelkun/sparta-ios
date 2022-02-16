//
//  LCDatesSelectorTableViewCell.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 14.02.2022.
//

import UIKit
import SpartaHelpers
import NetworkingModels

class LCDatesSelectorTableViewCell: UITableViewCell {

    // MARK: - Private properties

    private var dateSelectors: [LiveChartDateSelector]!
    private var selectedDateSelector: LiveChartDateSelector?
    private var _tapClosure: TypeClosure<LiveChartDateSelector>?

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("LCDatesSelectorTableViewCell")
    }

    // MARK: - Public methods

    func apply(dateSelectors: [LiveChartDateSelector],
               selectedDateSelector: LiveChartDateSelector?,
               onTap: @escaping TypeClosure<LiveChartDateSelector>) {

        self.dateSelectors = dateSelectors
        self.selectedDateSelector = selectedDateSelector
        _tapClosure = onTap

        setupUI()
    }

    // MARK: - Private methods

    private func setupUI() {

        backgroundColor = .clear
        selectedBackgroundView = UIView().then { $0.backgroundColor = .mainBackground }
        tintColor = .controlTintActive
        selectionStyle = .none

        let elementWidth: CGFloat = UIScreen.main.bounds.inset(by: .init(top: 0, left: 8, bottom: 0, right: 8)).width / 5
        let elementsSpace: CGFloat = 0

        func elementsCountFitWidth() -> Int {
            let screenWidthWithInsets = UIScreen.main.bounds.inset(by: .init(top: 0, left: 8, bottom: 0, right: 8)).width

            let elementFullWidth = elementWidth + elementsSpace

            var elementsCount: Int = 0
            while screenWidthWithInsets >= CGFloat(elementsCount) * elementFullWidth {
                elementsCount += 1
            }

            if CGFloat(elementsCount) * elementFullWidth > screenWidthWithInsets {
                elementsCount -= 1
            }

            return elementsCount
        }

        let items = dateSelectors.chunked(into: elementsCountFitWidth())

        var previousView: UIView?

        for (index, arrayItems) in items.enumerated() {
            previousView = UIStackView().then { horizontalSV in

                horizontalSV.alignment = .leading
                horizontalSV.axis = .horizontal
                horizontalSV.distribution = .equalSpacing
                horizontalSV.spacing = elementsSpace

                arrayItems.forEach { dateSelector in

                    let view = LCDatesSelectorItemView(
                        dateSelector: dateSelector,
                        isSelected: dateSelector == selectedDateSelector
                    ).then { dateSView in

                        dateSView.onTap { [unowned self] view in
                            guard let view = view as? LCDatesSelectorItemView else { return }

                            _tapClosure?(view.dateSelector)
                        }

                        dateSView.snp.makeConstraints {
                            $0.width.equalTo(elementWidth)
                        }
                    }

                    horizontalSV.addArrangedSubview(view)
                }

                contentView.addSubview(horizontalSV) {
                    $0.left.equalToSuperview().offset(10)

                    if let previousView = previousView {
                        $0.top.equalTo(previousView.snp.bottom).offset(11)
                    } else {
                        $0.top.equalToSuperview().offset(16)
                    }

                    if index == items.count - 1 { // means last item
                        $0.bottom.equalToSuperview().inset(16)
                    }
                }
            }
        }
    }
}
