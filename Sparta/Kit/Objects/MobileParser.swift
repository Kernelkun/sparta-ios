//
//  MobileParser.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 05.01.2022.
//

import Foundation
import PhoneNumberKit

protocol MobileParserDelegate: AnyObject {
    func mobileParserDidUpdateDataToNewCountry(_ parser: MobileParser, country: MobileParser.Country?)
}

class MobileParser {

    // MARK: - Pubic methods

    weak var delegate: MobileParserDelegate?

    let phoneNumberKit: PhoneNumberKit
    private(set) var defaultCode: String
    private(set) var country: MobileParser.Country?

    // MARK: - Initializers

    init(defaultCode: String) {
        self.defaultCode = defaultCode
        self.phoneNumberKit = PhoneNumberKit()

        country = .init(for: defaultCode, with: phoneNumberKit)
    }

    // MARK: - Static methods

    static func retreivePhoneNumber(from string: String) -> PhoneNumber? {
        let phoneNumberKit = PhoneNumberKit()
        return try? phoneNumberKit.parse(string)
    }

    static func generateNationalNumber(from phoneNumber: PhoneNumber) -> String {
        let phoneNumberKit = PhoneNumberKit()
        return phoneNumberKit.format(phoneNumber, toType: .e164, withPrefix: true)
    }

    // MARK: - Public methods

    func apply(phoneNumber: PhoneNumber) {
        defaultCode = phoneNumber.regionID ?? "UA"
        country = .init(for: defaultCode, with: phoneNumberKit)
        delegate?.mobileParserDidUpdateDataToNewCountry(self, country: country)
    }

    func updateCountryCode(_ countryCode: String) {
        defaultCode = countryCode
        country = .init(for: defaultCode, with: phoneNumberKit)
        delegate?.mobileParserDidUpdateDataToNewCountry(self, country: country)
    }
}

extension MobileParser {
    struct Country {
        var code: String
        var flag: String
        var name: String
        var prefix: String

        init?(for countryCode: String, with phoneNumberKit: PhoneNumberKit) {
            let flagBase = UnicodeScalar("🇦").value - UnicodeScalar("A").value
            guard
                let name = (Locale.current as NSLocale).localizedString(forCountryCode: countryCode),
                let prefix = phoneNumberKit.countryCode(for: countryCode)?.description
            else {
                return nil
            }

            self.code = countryCode
            self.name = name
            self.prefix = "+" + prefix
            self.flag = ""
            countryCode.uppercased().unicodeScalars.forEach {
                if let scaler = UnicodeScalar(flagBase + $0.value) {
                    flag.append(String(describing: scaler))
                }
            }
            if flag.count != 1 { // Failed to initialize a flag ... use an empty string
                return nil
            }
        }
    }
}
