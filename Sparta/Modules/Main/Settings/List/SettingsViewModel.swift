//
//  SettingsViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.12.2020.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels

protocol SettingsViewModelDelegate: AnyObject {
    func didLoadData()
}

class SettingsViewModel: NSObject, BaseViewModel {

    // MARK: - Public proprties

    weak var delegate: SettingsViewModelDelegate?

    var sections: [Section] = []

    // MARK: - Private properties

    // MARK: - Public methods

    func loadData() {

        let mainSection = Section(name: .settings, rows: [.account, /*.subscription, .alarms, .support*/])

        sections = [mainSection]

        delegate?.didLoadData()
    }

    func logout() {
        App.instance.logout()
    }
}

extension SettingsViewModel {

    enum SectionName {

        case settings

        var displayName: String {
            switch self {
            case .settings: return ""
            }
        }
    }

    enum RowName {

        case account
        case subscription
        case alarms
        case support

        var displayName: String {
            switch self {
            case .account: return "SettingsPage.List.Account.Title".localized
            case .subscription: return "Subscription"
            case .alarms: return "Alarms"
            case .support: return "Support"
            }
        }
    }

    struct Section {
        let name: SectionName
        let rows: [RowName]
    }
}
