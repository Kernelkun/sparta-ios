//
//  ArbDetailContentView.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 28.01.2021.
//

import UIKit
import SpartaHelpers
import NetworkingModels

class ArbDetailContentView: UIView {

    // MARK: - Private UI

    private var mainStackView: UIStackView!

    // MARK: - Private properties

    private var _onMarginChangedClosure: TypeClosure<String>?

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("ArbDetailContentView")
    }

    // MARK: - Public methods

    func applyCells(_ newCells: [ArbDetailViewModel.Cell]) {
        mainStackView.removeAllSubviews()

        newCells.forEach { cell in

            switch cell {
            case .status(let position):
                mainStackView.addArrangedSubview(statusView(title: cell.displayTitle,
                                                            position: position))

            case .target(let value):
                mainStackView.addArrangedSubview(inputView(title: cell.displayTitle, value: value))

            case .emptySpace:
                mainStackView.addArrangedSubview(emptyView())

            case .blendCost(let value, let color), .gasNap(let value, let color),
                 .freight(let value, let color), .taArb(let value, let color),
                 .dlvPrice(let value, let color), .dlvPriceBasis(let value, let color),
                 .myMargin(let value, let color), .blenderMargin(let value, let color),
                 .fobRefyMargin(let value, let color), .cifRefyMargin(let value, let color),
                 .codBlenderMargin(let value, let color), .ew(let value, let color):

                mainStackView.addArrangedSubview(keyValueView(title: cell.displayTitle, value: value, color: color))
            }
        }
    }

    func reloadCells(_ newCells: [ArbDetailViewModel.Cell]) {

        newCells.forEach { cell in

            switch cell {
            case .status(let position):

                if let subview: ResultAutoStatusView<String> = findSubviews(cell.displayTitle).first {
                    subview.apply(key: cell.displayTitle, position: position)
                }

            case .blendCost(let value, let color), .gasNap(let value, let color),
                 .freight(let value, let color), .taArb(let value, let color),
                 .dlvPrice(let value, let color), .dlvPriceBasis(let value, let color),
                 .myMargin(let value, let color), .blenderMargin(let value, let color),
                 .fobRefyMargin(let value, let color), .cifRefyMargin(let value, let color),
                 .codBlenderMargin(let value, let color):

                if let subview: ResultKeyValueView<String> = findSubviews(cell.displayTitle).first {
                    subview.apply(key: cell.displayTitle, value: value, valueColor: color)
                }

            default:
                break
            }
        }
    }

    func onMarginChanged(completion: @escaping TypeClosure<String>) {
        _onMarginChangedClosure = completion
    }

    // MARK: - Private methods

    private func setupUI() {

        // main stack view

        mainStackView = UIStackView().then { stackView in

            stackView.axis = .vertical
            stackView.distribution = .equalSpacing
            stackView.spacing = 9
            stackView.alignment = .fill

            addSubview(stackView) {
                $0.edges.equalToSuperview()
            }
        }
    }

    private func emptyView() -> UIView {
        UIView().then { view in

            view.backgroundColor = .clear

            view.snp.makeConstraints {
                $0.height.equalTo(11)
            }
        }
    }

    private func keyValueView(title: String, value: String, color: UIColor, height: CGFloat = 38) -> ResultKeyValueView<String> {
        ResultKeyValueView(id: title).then { view in

            view.apply(key: title, value: value, valueColor: color)

            view.snp.makeConstraints {
                $0.height.equalTo(height)
            }
        }
    }

    private func inputView(title: String, value: String?, height: CGFloat = 38) -> ResultKeyInputView {
        ResultKeyInputView().then { view in

            view.apply(key: title, value: value) { [unowned self] text in
                self._onMarginChangedClosure?(text)
            }

            view.snp.makeConstraints {
                $0.height.equalTo(height)
            }
        }
    }

    private func statusView(title: String, position: ArbMonth.Position?, height: CGFloat = 38) -> ResultAutoStatusView<String> {
        ResultAutoStatusView(id: title).then { view in

            view.apply(key: title, position: position)

            view.snp.makeConstraints {
                $0.height.equalTo(height)
            }
        }
    }

    private func findSubviews<S: Identifiable>(_ id: String) -> [S] where S: UIView, S.ID: StringProtocol {
        mainStackView.arrangedSubviews.compactMap {
            if let subview = $0 as? S, subview.id == id {
                return subview
            } else { return nil }
        }
    }
}
