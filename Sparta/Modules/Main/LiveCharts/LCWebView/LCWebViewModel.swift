//
//  LCWebViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 03.02.2022.
//

import UIKit
import App
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

    private var isLoading: Bool = false {
        didSet {
            onMainThread {
                self.delegate?.didChangeLoadingState(self.isLoading)
            }
        }
    }

    private let itemsSaver = LCWebSaver()
    private let liveCurvesNetworkManager = LiveCurvesNetworkManager()
    private let liveChartsNetworkManager = LiveChartsNetworkManager()
    private let liveChartsSyncManager = LiveChartsSyncManager()

    // MARK: - Initializers

    override init() {
        super.init()

        liveChartsSyncManager.delegate = self
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
        liveCurvesNetworkManager.fetchLiveChartsProducts { result in
            if case let .success(responseModel) = result,
               let list = responseModel.model?.list {
                
                items = list//.filter({ LCWebRestriction.validItemsCodes.contains($0.code) })
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

            if let defaultItem = items.first(where: { LCWebRestriction.defaultItemCode == $0.code }),
               strongSelf.configurator == nil {

                onMainThread {
                    strongSelf.apply(configurator: Configurator(item: Item(item: defaultItem)))
                }
            } else if let firstItem = items.first, strongSelf.configurator == nil {

                onMainThread {
                    strongSelf.apply(configurator: Configurator(item: Item(item: firstItem)))
                }
            } else {
                strongSelf.isLoading = false
            }
        }
    }

    func apply(configurator: LCWebViewModel.Configurator) {
        isLoading = true
        self.configurator = configurator

        print("CONFIGURATOR ***: \(configurator)")

        let item = configurator.item

        liveChartsNetworkManager.fetchDateSelectors(code: item.code) { [weak self] result in
            guard let strongSelf = self else { return }

            if case let .success(responseModel) = result,
                let list = responseModel.model?.list,
                let firstItem = list.first {

                strongSelf.configurator?.dateSelectors = list

                if let dateSelector = strongSelf.configurator?.dateSelector,
                   let foundSelector = list.first(where: { $0.code.lowercased() == dateSelector.code.lowercased() }) {

                    strongSelf.setDate(LCWebViewModel.DateSelector(dateSelector: foundSelector))
                } else if let savedDateSelector = strongSelf.itemsSaver.dateSelector(of: strongSelf.configurator.required().item.code) {
                    strongSelf.setDate(savedDateSelector)
                } else if list.count >= 1 {
                    let secondItem = list[1]
                    strongSelf.setDate(LCWebViewModel.DateSelector(dateSelector: secondItem))
                } else {
                    strongSelf.setDate(LCWebViewModel.DateSelector(dateSelector: firstItem))
                }
            } else {
                strongSelf.presentHighlightsSkeleton()

                onMainThread {
                    strongSelf.isLoading = false
                    strongSelf.delegate?.didSuccessUpdateConfigurator(strongSelf.configurator.required())
                }
            }
        }
    }

    func setDate(_ dateSelector: DateSelector) {
        guard self.configurator != nil else { return }

        self.configurator?.dateSelector = dateSelector

        let item = LCWebSaver.Item(
            item: self.configurator.required().item,
            dateSelector: dateSelector
        )

        itemsSaver.saveItem(item)

        onMainThread {
            self.delegate?.didSuccessUpdateDateSelector(dateSelector)
        }

        let configurator = self.configurator.required()
        liveChartsNetworkManager.fetchHighlights(
            code: configurator.item.code,
            tenorCode: configurator.dateSelector.required().code
        ) { [weak self] result in
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
                        if let highlight = findHighlight(for: "day"),
                            !highlights.contains(where: { $0.type == .open }),
                            let value = highlight.open?.symbols2Value {

                            highlights.append(.init(type: .open, value: value))
                        } else {
                            highlights.append(.init(type: .open, value: "-"))
                        }

                    case .previousClose:
                        if let highlight = findHighlight(for: "previous"),
                            !highlights.contains(where: { $0.type == .previousClose }),
                            let value = highlight.close?.symbols2Value {

                            highlights.append(.init(type: .previousClose, value: value))
                        } else {
                            highlights.append(.init(type: .previousClose, value: "-"))
                        }

                    case .week52Low:
                        if let highlight = findHighlight(for: "52-weeks"),
                            !highlights.contains(where: { $0.type == .week52Low }),
                            let value = highlight.low?.symbols2Value {

                            highlights.append(.init(type: .week52Low, value: value))
                        } else {
                            highlights.append(.init(type: .week52Low, value: "-"))
                        }

                    case .week52High:
                        if let highlight = findHighlight(for: "52-weeks"),
                            !highlights.contains(where: { $0.type == .week52High }),
                            let value = highlight.high?.symbols2Value {

                            highlights.append(.init(type: .week52High, value: value))
                        } else {
                            highlights.append(.init(type: .week52High, value: "-"))
                        }

                    case .monthLow:
                        if let highlight = findHighlight(for: "month"),
                            !highlights.contains(where: { $0.type == .monthLow }),
                            let value = highlight.low?.symbols2Value {

                            highlights.append(.init(type: .monthLow, value: value))
                        } else {
                            highlights.append(.init(type: .monthLow, value: "-"))
                        }

                    case .monthHigh:
                        if let highlight = findHighlight(for: "month"),
                            !highlights.contains(where: { $0.type == .monthHigh }),
                            let value = highlight.high?.symbols2Value {

                            highlights.append(.init(type: .monthHigh, value: value))
                        } else {
                            highlights.append(.init(type: .monthHigh, value: "-"))
                        }
                    }
                }

                strongSelf.configurator?.highlights = highlights
                strongSelf.startLive()

                onMainThread {
                    strongSelf.isLoading = false
                    strongSelf.delegate?.didSuccessUpdateConfigurator(strongSelf.configurator.required())
                }
            } else {
                strongSelf.presentHighlightsSkeleton()

                onMainThread {
                    strongSelf.isLoading = false
                    strongSelf.delegate?.didSuccessUpdateConfigurator(strongSelf.configurator.required())
                }
            }
        }
    }

    func startLive() {
        guard let configurator = configurator, let dateSelector = configurator.dateSelector else { return }

        liveChartsSyncManager.startObserving(
            itemCode: configurator.item.code,
            tenorName: dateSelector.code
        )
    }

    func stopLive() {
        liveChartsSyncManager.stopObserving()
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

    private func presentHighlightsSkeleton() {
        var highlights: [Highlight] = []

        for type in Highlight.HighlightType.allCases {
            switch type {
            case .open:
                highlights.append(.init(type: .open, value: "-"))

            case .previousClose:
                highlights.append(.init(type: .previousClose, value: "-"))

            case .week52Low:
                highlights.append(.init(type: .week52Low, value: "-"))

            case .week52High:
                highlights.append(.init(type: .week52High, value: "-"))

            case .monthLow:
                highlights.append(.init(type: .monthLow, value: "-"))

            case .monthHigh:
                highlights.append(.init(type: .monthHigh, value: "-"))
            }
        }

        configurator?.highlights = highlights
        startLive()

        onMainThread {
            self.isLoading = false
            self.delegate?.didSuccessUpdateConfigurator(self.configurator.required())
        }
    }
}

extension LCWebViewModel: LiveChartsSyncManagerDelegate {

    func liveChartsSyncManagerDidReceive(highlight: LiveChartHighlightSocket) {
        guard let configurator = configurator,
              configurator.item.code == highlight.spartaCode,
              let dateSelector = configurator.dateSelector,
              dateSelector.code == highlight.tenorName,
              let resolution = Environment.LiveChart.Resolution(rawValue: highlight.resolution) else { return }

        var highlights: [Highlight] = self.configurator.required().highlights

        func index(of type: Highlight.HighlightType) -> Int? {
            highlights.firstIndex(where: { $0.type == type })
        }

        switch resolution {
        case .minute1:
            break
            
        case .hour1:
            break

        case .day1:
            if let index = index(of: .open),
                let value = highlight.open?.symbols2Value {

                highlights[index].value = value
            }

        case .week1:
            break

        case .month1:
            if let index = index(of: .monthHigh),
                let value = highlight.high?.symbols2Value {

                highlights[index].value = value
            }

            if let index = index(of: .monthLow),
                let value = highlight.low?.symbols2Value {

                highlights[index].value = value
            }

        case .week52:
            if let index = index(of: .week52Low),
                let value = highlight.low?.symbols2Value {

                highlights[index].value = value
            }

            if let index = index(of: .week52High),
                let value = highlight.high?.symbols2Value {

                highlights[index].value = value
            }
        }

        self.configurator?.highlights = highlights

        onMainThread {
            self.delegate?.didSuccessUpdateHighlights(highlights)
        }
    }
}
