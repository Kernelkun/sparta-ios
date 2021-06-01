//
//  AccountSettingsViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.12.2020.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels
import PhoneNumberKit
import SpartaHelpers

protocol AccountSettingsViewModelDelegate: AnyObject {
    func didLoadData()
    func didReloadTradeOptions()
    func didCatchAnError(_ error: String)
    func didChangeSendingState(_ isSending: Bool, for state: AccountSettingsViewModel.LoadingState)
}

class AccountSettingsViewModel: NSObject, BaseViewModel {

    //
    // MARK: - Public properties

    var countriesCodes: [CountryCodeModel] {
        _phonePrefixes.compactMap { createCountryCodeModel(from: $0) }
    }

    var tradeAreas: [PickerIdValued<Int>] = []
    var ports: [PickerIdValued<Int>] = []
    var products: [PickerIdValued<Int>] = []
    var userRoles: [PickerIdValued<Int>] = []

    weak var delegate: AccountSettingsViewModelDelegate?

    var selectedFirstName: String?
    var selectedLastName: String?

    var selectedCountryCode: CountryCodeModel?
    var selectedPhoneNumber: String?

    var selectedUserRole: PickerIdValued<Int>?
    var selectedPrimaryProduct: PickerIdValued<Int>?
    var selectedTradeArea: PickerIdValued<Int>?
    var selectedPort: PickerIdValued<Int>?

    //
    // MARK: - Private properties

    private let app = App.instance
    private let phoneNumberKit = PhoneNumberKit()
    private let profileNetworkManager = ProfileNetworkManager()

    private var _phonePrefixes: [PhonePrefix] {
        app.syncService.phonePrefixes ?? []
    }

    private var _userRoles: [UserRole] {
        app.syncService.userRoles ?? []
    }

    private var _tradeAreas: [TradeArea] {
        app.syncService.tradeAreas ?? []
    }

    // MARK: - Public methods

    func loadData() {
        changeLoadingState(true, for: .load)

        profileNetworkManager.fetchProfile { [weak self] result in
            guard let strongSelf = self else { return }

            strongSelf.changeLoadingState(false, for: .load)

            switch result {
            case .success(let responseModel) where responseModel.model != nil:

                App.instance.saveUser(responseModel.model!) //swiftlint:disable:this force_unwrapping

            case .failure, .success:
                break
            }

            strongSelf.handleCurrentUserData()
        }
    }

    func reloadTradesOptions() {

        // setup new product array based on choosed user role

        if let selectedUserRole = selectedUserRole,
           let selectedRole = _userRoles.first(where: { $0.id == selectedUserRole.id } ) {

            products = selectedRole.primaryProducts.compactMap { PickerIdValued(id: $0.id, title: $0.name, fullTitle: $0.name) }
        } else {
            products = []
        }

        // setup new ports array based on choosed trade area

        if let selectedTradeArea = selectedTradeArea,
           let selectedArea = _tradeAreas.first(where: { $0.id == selectedTradeArea.id } ) {

            ports = selectedArea.primaryPorts.compactMap { PickerIdValued(id: $0.id, title: $0.name, fullTitle: $0.name) }
        } else {
            ports = []
        }

        // clean product if needed

        if let selectedPrimaryProduct = selectedPrimaryProduct, !products.contains(selectedPrimaryProduct) {
            self.selectedPrimaryProduct = nil
        }

        // clear port if needed

        if let selectedPort = selectedPort, !ports.contains(selectedPort) {
            self.selectedPort = nil
        }

        // reload data

        onMainThread {
            self.delegate?.didReloadTradeOptions()
        }
    }

    func saveData() {

        guard let userId = app.currentUser?.id else {
            delegate?.didCatchAnError("Ups, Something wrong happened. User not found.")
            return
        }

        guard let selectedCountryCode = selectedCountryCode else {
            delegate?.didCatchAnError("Select please phone country code")
            return
        }

        guard let selectedPhoneNumber = selectedPhoneNumber else {
            delegate?.didCatchAnError("Enter please phone number")
            return
        }

        guard let selectedUserRole = selectedUserRole else {
            delegate?.didCatchAnError("Select please user role")
            return
        }

        var parameters: Parameters = [:]

        parameters["mobile_prefix"] = selectedCountryCode.id
        parameters["mobile_number"] = selectedPhoneNumber
        parameters["user_role"] = selectedUserRole.id

        if let selectedPrimaryProduct = selectedPrimaryProduct {
            parameters["primary_product"] = selectedPrimaryProduct.id
        }

        if let selectedTradeArea = selectedTradeArea {
            parameters["primary_trade_region"] = selectedTradeArea.id
        }

        if let selectedPort = selectedPort {
            parameters["primary_port"] = selectedPort.id
        }

        if let selectedFirstName = selectedFirstName {
            parameters["name"] = selectedFirstName
        }

        if let selectedLastName = selectedLastName {
            parameters["lastname"] = selectedLastName
        }

        changeLoadingState(true, for: .save)

        profileNetworkManager.updateUser(id: userId, parameters: parameters) { [weak self] result in
            guard let strongSelf = self else { return }

            strongSelf.changeLoadingState(false, for: .save)

            switch result {
            case .success(let responseModel) where responseModel.model != nil:

                break

            case .failure, .success:
                onMainThread {
                    strongSelf.delegate?.didCatchAnError("Ups, Something wrong happened with saving data.")
                }
            }
        }
    }

    // MARK: - Private methods

    private func changeLoadingState(_ isLoading: Bool, for state: AccountSettingsViewModel.LoadingState) {
        onMainThread {
            self.delegate?.didChangeSendingState(isLoading, for: state)
        }
    }

    private func createCountryCodeModel(from phonePrefix: PhonePrefix) -> CountryCodeModel {
        let code = phonePrefix.prefix
        let name = phonePrefix.name.capitalized
        let fullTitle = name + " " + code
        return CountryCodeModel(id: phonePrefix.id,
                                title: code,
                                fullTitle: fullTitle,
                                name: name,
                                code: code)
    }

    private func handleCurrentUserData() {

        let user = App.instance.currentUser

        // first/last name

        selectedFirstName = user?.firstName
        selectedLastName = user?.lastName

        // phone number

        if let mobilePrefixIndex = user?.mobilePrefixIndex,
           let phonePrefix = _phonePrefixes.first(where: { $0.id == mobilePrefixIndex }) {

            selectedCountryCode = createCountryCodeModel(from: phonePrefix)
        }

        selectedPhoneNumber = user?.mobileNumber

        // role

        if let selectedUserRoleIndex = user?.role,
           let userRole = _userRoles.first(where: { $0.id == selectedUserRoleIndex }) {

            selectedUserRole = PickerIdValued(id: userRole.id, title: userRole.name, fullTitle: userRole.name)
        }

        // product

        if let selectedPrimaryProductIndex = user?.primaryProduct,
           let selectedRole = _userRoles.first(where: { $0.primaryProducts.contains(where: { $0.id == selectedPrimaryProductIndex }) }),
           let selectedProduct = selectedRole.primaryProducts.first(where: { $0.id == selectedPrimaryProductIndex })  {

            selectedPrimaryProduct = PickerIdValued(id: selectedProduct.id, title: selectedProduct.name, fullTitle: selectedProduct.name)
        }

        // trade area

        if let selectedTradeAreaIndex = user?.primaryTradeRegion,
           let selectedTradeArea = _tradeAreas.first(where: { $0.id == selectedTradeAreaIndex }) {

            self.selectedTradeArea = PickerIdValued(id: selectedTradeArea.id, title: selectedTradeArea.name, fullTitle: selectedTradeArea.name)
        }

        // port

        if let selectedPortIndex = user?.primaryPort,
           let selectedTradeArea = _tradeAreas.first(where: { $0.primaryPorts.contains(where: { $0.id == selectedPortIndex }) }),
           let selectedPort = selectedTradeArea.primaryPorts.first(where: { $0.id == selectedPortIndex }) {

            self.selectedPort = PickerIdValued(id: selectedPort.id, title: selectedPort.name, fullTitle: selectedPort.name)
        }

        userRoles = _userRoles.compactMap { PickerIdValued(id: $0.id, title: $0.name, fullTitle: $0.name) }
        tradeAreas = _tradeAreas.compactMap { PickerIdValued(id: $0.id, title: $0.name, fullTitle: $0.name) }

        // reload data

        reloadTradesOptions()

        onMainThread {
            self.delegate?.didLoadData()
        }
    }
}
