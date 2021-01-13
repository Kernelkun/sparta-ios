//
//  FreightViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.12.2020.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels
import SpartaHelpers

protocol FreightViewModelDelegate: class {
    func didCatchAnError(_ error: String)
    func didLoadData()
    func didReloadMainOptions()
    func didFinishCalculations(with inputData: FreightCalculator.InputData)
}

class FreightViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    weak var delegate: FreightViewModelDelegate?

    var months: [PickerIdValued<Date>] = []
    var freightPorts: [PickerIdValued<Int>] = []
    var dischargePorts: [PickerIdValued<Int>] = []
    var vesselTypes: [PickerIdValued<Vessel>] = []

    // selection

    var selectedMonth: PickerIdValued<Date>?
    var selectedFreightPort: PickerIdValued<Int>?
    var selectedDischargePort: PickerIdValued<Int>?
    var selectedVesselType: PickerIdValued<Vessel>?
    var selectedVesselSpeed: String?
    var selectedLoadedQuantity: String?

    // MARK: - Private properties

    private let analyticsNetworkManager = AnalyticsNetworkManager()
    private let app = App.instance

    // MARK: - Public methods

    func loadData() {

        // months

        loadMonths()

        // freight & discharge ports

        loadFreightAndDischargePorts()

        delegate?.didLoadData()
    }

    func saveData() {

        guard let selectedMonth = selectedMonth else {
            delegate?.didCatchAnError("Please select month")
            return
        }

        guard let selectedPort = selectedFreightPort else {
            delegate?.didCatchAnError("Please select port")
            return
        }

        guard let selectedDischargePort = selectedDischargePort else {
            delegate?.didCatchAnError("Please select discharge port")
            return
        }

        guard let selectedVesselType = selectedVesselType else {
            delegate?.didCatchAnError("Please select vessel type")
            return
        }

        guard let selectedVesselSpeed = selectedVesselSpeed else {
            delegate?.didCatchAnError("Please enter vessel speed")
            return
        }

        guard let selectedLoadedQuantity = selectedLoadedQuantity else {
            delegate?.didCatchAnError("Please enter loaded quantity")
            return
        }

        let inputData = FreightCalculator.InputData(month: selectedMonth.id,
                                                    portId: selectedPort.id,
                                                    dischargePortId: selectedDischargePort.id,
                                                    vessel: selectedVesselType.id,
                                                    vesselSpeed: selectedVesselSpeed.toDouble ?? 0.0,
                                                    loadedQuantity: selectedLoadedQuantity.toDouble ?? 0.0)

        onMainThread {
            self.delegate?.didFinishCalculations(with: inputData)
        }
    }

    func reloadMainOptions() {

        if let selectedFreightPort = selectedFreightPort,
           let freightPort = app.syncService.freightPorts?.first(where: { $0.id == selectedFreightPort.id }) {

            dischargePorts = freightPort.dischargePorts.compactMap {
                let model = PickerIdValued(id: $0.id, title: $0.name, fullTitle: $0.name)
                return model
            }
            .sorted(by: { $0.title < $1.title })
        }

        // clean discharge port if needed

        if let selectedFreightPort = selectedFreightPort,
           let selectedDischargePort = selectedDischargePort,
           let freightPort = app.syncService.freightPorts?.first(where: { $0.id == selectedFreightPort.id }),
           !freightPort.dischargePorts.contains(where: { $0.id == selectedDischargePort.id }) {

            self.selectedDischargePort = nil
        }

        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        fetchFreightRoute { [weak self] freightRoute in
            guard let strongSelf = self else { return }

            guard let freightRoute = freightRoute else {
                strongSelf.vesselTypes = []
                strongSelf.selectedVesselType = nil

                dispatchGroup.leave()

                return
            }

            strongSelf.vesselTypes = freightRoute.vessels.compactMap { .init(id: $0, title: $0.type, fullTitle: $0.type) }

            guard let selectedVesselType = strongSelf.selectedVesselType,
                  strongSelf.vesselTypes.contains(selectedVesselType) else {

                strongSelf.selectedVesselType = nil
                dispatchGroup.leave()
                return
            }

            strongSelf.selectedVesselSpeed = selectedVesselType.id.speed.toFormattedString
            strongSelf.selectedLoadedQuantity = selectedVesselType.id.loadedQuantity.toFormattedString

            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            self.delegate?.didReloadMainOptions()
        }
    }

    // MARK: - Private methods

    private func loadMonths() {
        months = Date.fetchNextMonths(count: 14).compactMap { date in
            let title = date.formattedString(AppFormatter.fullMonthAndYear)
            let model = PickerIdValued(id: date, title: title, fullTitle: title)
            return model
        }
    }

    private func loadFreightAndDischargePorts() {
        freightPorts = app.syncService.freightPorts?.compactMap {
            let model = PickerIdValued(id: $0.id, title: $0.name, fullTitle: $0.name)
            return model
        }
        .sorted(by: { $0.fullTitle < $1.fullTitle }) ?? []
    }

    private func fetchFreightRoute(completion: @escaping TypeClosure<FreightRoute?>) {

        guard let selectedDischargePort = selectedDischargePort,
              let selectedMonth = selectedMonth,
              let selectedFreightPort = selectedFreightPort else {

            completion(nil)
            return
        }

        analyticsNetworkManager.fetchFreightRoute(loadPortId: selectedFreightPort.id,
                                                  dischargePortId: selectedDischargePort.id,
                                                  selectedDate: selectedMonth.id.formattedString(AppFormatter.serverShortDate)) { result in
            switch result {
            case .success(let responseModel) where responseModel.model != nil:

                completion(responseModel.model!) //swiftlint:disable:this force_unwrapping

            case .success, .failure:

                completion(nil)
            }
        }
    }
}
