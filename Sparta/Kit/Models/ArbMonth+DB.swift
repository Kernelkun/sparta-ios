//
//  ArbMonth+DB.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 22.01.2021.
//

import Foundation
import NetworkingModels

struct ArbMonthDBProperties {

    typealias UserTarget = Double

    // MARK: - Private properties

    private let month: ArbMonth

    // MARK: - Initializers

    init(month: ArbMonth) {
        self.month = month
    }

    // MARK: - Public methods

    func fetchUserTarget() -> UserTarget? {
        return DBUserTarget.fetch(with: month.uniqueIdentifier)?.target
    }

    func saveUserTarget(value: UserTarget) {
        DBUserTarget.createOrUpdate(id: month.uniqueIdentifier, target: value, completion: {})
    }
}

extension ArbMonth {
    var dbProperties: ArbMonthDBProperties {
        ArbMonthDBProperties(month: self)
    }
}
