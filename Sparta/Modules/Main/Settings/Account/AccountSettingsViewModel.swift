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

protocol AccountSettingsViewModelDelegate: class {
    func didLoadData()
}

struct TestModel: NamedModel {

    var name: String
}

class AccountSettingsViewModel: NSObject, BaseViewModel {

    // MARK: - Public properties

    var countriesCodes: [TestModel] {
        phoneNumberKit.allCountries().compactMap {
            guard let countryCode = phoneNumberKit.countryCode(for: $0) else { return nil }

            return TestModel(name: "+" + String(countryCode))
        }
    }

    weak var delegate: AccountSettingsViewModelDelegate?

    // MARK: - Private properties

    private let phoneNumberKit = PhoneNumberKit()

    // MARK: - Public methods

    func loadData() {

        delegate?.didLoadData()
    }
}
