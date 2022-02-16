//
//  LCWebViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 03.02.2022.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels
import SpartaHelpers

class LCWebViewModel: NSObject, BaseViewModel, LCWebViewModelInterface {

    // MARK: - Public properties

    weak var delegate: LCWebViewModelDelegate?

    private(set) var groups: [LCWebViewModel.Group] = []
    private(set) var configurator: Configurator?

    // MARK: - Private properties

    var isLoading: Bool = false {
        didSet {
            onMainThread {
                self.delegate?.didChangeLoadingState(self.isLoading)
            }
        }
    }

    private let liveCurvesNetworkManager = LiveCurvesNetworkManager()
    private let liveChartsNetworkManager = LiveChartsNetworkManager()

    // MARK: - Initializers

    override init() {
        super.init()
    }

    deinit {
    }

    // MARK: - Public methods

    func loadData() {
        isLoading = true

        let group = DispatchGroup()

        var groups: [LiveCurveProfileGroup] = []
        var items: [LiveCurveProfileProduct] = []

        group.enter()
        liveCurvesNetworkManager.fetchProducts { result in
            if case let .success(responseModel) = result,
               let list = responseModel.model?.list {
                
                items = list.filter({ LCWebRestriction.validItemsCodes.contains($0.code) })
            }

            group.leave()
        }

        group.enter()
        liveCurvesNetworkManager.fetchProductGroups { result in
            if case let .success(responseModel) = result,
               let list = responseModel.model?.list {

                groups = list
            }

            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }

            let groups = strongSelf.configureGroups(serverGroups: groups,
                                                    serverItems: items.sorted(by: { $0.shortName < $1.shortName }))
            strongSelf.groups = groups

            if let firstItem = items.first, strongSelf.configurator == nil {
                onMainThread {
                    strongSelf.apply(configurator: Configurator(item: Item(item: firstItem)))
                }
            }
        }
    }

    func apply(configurator: LCWebViewModel.Configurator) {
        self.configurator = configurator

        let item = configurator.item
        delegate?.didSuccessUpdateConfigurator(configurator)

        liveChartsNetworkManager.fetchDateSelectors(code: item.code) { [weak self] result in
            guard let strongSelf = self else { return }

            if case let .success(responseModel) = result,
                    let list = responseModel.model?.list.filter({ LCWebRestriction.validDateSelectors.contains($0.code) }),
                    let firstItem = list.first {

                strongSelf.configurator?.dateSelectors = list

                if let dateSelector = strongSelf.configurator?.dateSelector,
                   let foundSelector = list.first(where: { $0.code.lowercased() == dateSelector.code.lowercased() }) {

                    strongSelf.setDate(LCWebViewModel.DateSelector(dateSelector: foundSelector))
                } else {
                    strongSelf.setDate(LCWebViewModel.DateSelector(dateSelector: firstItem))
                }
            }
        }
    }

    func setDate(_ dateSelector: DateSelector) {
        guard self.configurator != nil else { return }

        self.configurator?.dateSelector = dateSelector

        onMainThread {
            self.delegate?.didSuccessUpdateConfigurator(self.configurator.required())
        }

        let configurator = self.configurator.required()
        liveChartsNetworkManager.fetchHighlights(code: configurator.item.code, tenorCode: configurator.dateSelector.required().code) { [weak self] result in
            guard let strongSelf = self else { return }

            if case let .success(responseModel) = result,
               let list = responseModel.model?.list {

                var highlights: [Highlight] = []

                func findHighlight(for fieldName: String) -> LiveChartHighlight? {
                    list.first(where: { $0.field == fieldName })
                }

                for type in Highlight.HighlightType.allCases {
                    switch type {
                    case .open:
                        if let highlight = findHighlight(for: "day") {
                            highlights.append(.init(type: .open, value: highlight.open.symbols2Value))
                        }

                    case .previousClose:
                        if let highlight = findHighlight(for: "yesterday") {
                            highlights.append(.init(type: .previousClose, value: highlight.close.symbols2Value))
                        }

                    case .week52Low:
                        if let highlight = findHighlight(for: "52-weeks") {
                            highlights.append(.init(type: .week52Low, value: highlight.low.symbols2Value))
                        }

                    case .week52High:
                        if let highlight = findHighlight(for: "52-weeks") {
                            highlights.append(.init(type: .week52High, value: highlight.high.symbols2Value))
                        }

                    case .monthLow:
                        if let highlight = findHighlight(for: "month") {
                            highlights.append(.init(type: .monthLow, value: highlight.low.symbols2Value))
                        }

                    case .monthHigh:
                        if let highlight = findHighlight(for: "month") {
                            highlights.append(.init(type: .monthHigh, value: highlight.high.symbols2Value))
                        }
                    }
                }

                strongSelf.configurator?.highlights = highlights

                onMainThread {
                    strongSelf.delegate?.didSuccessUpdateConfigurator(strongSelf.configurator.required())
                }
            } else {
                onMainThread {
                    strongSelf.delegate?.didSuccessUpdateConfigurator(strongSelf.configurator.required())
                }
            }
        }
    }

    // MARK: - Private methods

    private func configureGroups(serverGroups: [LiveCurveProfileGroup],
                                 serverItems: [LiveCurveProfileProduct]) -> [LCWebViewModel.Group] {

        // groups

        var groups = serverGroups.compactMap { LCWebViewModel.Group(group: $0) }

        // items

        serverItems.forEach { product in
            product.productGroups.forEach { group in
                if let indexOfGroup = groups.firstIndex(where: { group.id == $0.id }) {
                    let item = LCWebViewModel.Item(item: product)
                    groups[indexOfGroup].items.append(item)
                }
            }
        }

        return groups.filter { !$0.items.isEmpty }
    }
}
