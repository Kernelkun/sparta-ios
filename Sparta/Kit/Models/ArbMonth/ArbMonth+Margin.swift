//
//  ArbMonth+Margin.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.01.2021.
//

import UIKit
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
        return month.userTarget
    }

    func saveUserTarget(value: UserTarget) {
        ArbsSyncManager.intance.updateUserTarget(value, for: month)
    }

    func deleteUserTarget() {
        ArbsSyncManager.intance.deleteUserTarget(for: month)
    }
}

// extended structs for ArbMonth

extension ArbMonth {

    enum Margin: String {
        case auto
        case manual
    }

    enum Position {
        case first
        case second
        case third
        case fourth
        case fifth

        var percentage: Double {
            switch self {
            case .first:
                return 20

            case .second:
                return 33

            case .third:
                return 50

            case .fourth:
                return 66

            case .fifth:
                return 100
            }
        }

        var color: UIColor {
            switch self {
            case .first:
                return UIColor(hex: 0xFF4938)

            case .second:
                return UIColor(hex: 0xFF8C1B)

            case .third:
                return UIColor(hex: 0xF6C906)

            case .fourth:
                return UIColor(hex: 0xC5CD1F)

            case .fifth:
                return UIColor(hex: 0x33DC6A)
            }
        }
    }
}

extension ArbMonth {

    var dbProperties: ArbMonthDBProperties {
        ArbMonthDBProperties(month: self)
    }

    var marginType: Margin {
        gradesWithAutomatedMargin.contains(gradeCode) ? .auto : .manual
    }

    var position: Position? {

        if let calculatedUserMargin = calculatedUserMargin {
            if calculatedUserMargin > 0 {
                return .fifth
            } else {
                return .first
            }
        } else if marginType == .manual { return nil }

        let total: Int = [genericBlenderMargin, pseudoFobRefinery, pseudoCifRefinery].compactMap { $0?.valueIndex }.reduce(0, +)

        if gradeCode == "E5EUROBOB" {
            switch total {
            case let total where total <= 0:
                return .first

            case let total where total == 1:
                return .third

            default:
                return .fifth
            }
        } else {
            switch total {
            case let total where total <= 0:
                return .first

            case let total where total == 1:
                return .second

            case let total where total == 2:
                return .fourth

            default:
                return .fifth
            }
        }
    }

    var calculatedUserMargin: Double? {
        guard let userTarget = dbProperties.fetchUserTarget(),
              let deliveryPrice = deliveredPrice?.value.value.toDouble else { return nil }

        return Double(userTarget) - deliveryPrice
    }

    // MARK: - Private properties

    private var gradesWithAutomatedMargin: [String] {
        ["E5EUROBOB", "RBOB", "SING92RON", "SING92RONHOUREF"]
    }
}

fileprivate extension ColoredNumber {

    var valueIndex: Int {
        switch color.lowercased() {
        case "red":
            return 0
        case "green":
            return 1
        case "gray":
            return 0
        default: return 0
        }
    }
}
