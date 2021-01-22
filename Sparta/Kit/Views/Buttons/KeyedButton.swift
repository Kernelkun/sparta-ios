//
//  KeyedButton.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 22.01.2021.
//

import UIKit

class KeyedButton<K: StringProtocol>: TappableButton {

    // MARK: - Public properties

    private(set) var key: K?

    // MARK: - Public methods

    func setKey(_ key: K) {
        self.key = key
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? KeyedLabel<K>,
              object.key != nil,
              key != nil  else { return false }

        return self.key?.lowercased() == object.key?.lowercased()
    }
}
