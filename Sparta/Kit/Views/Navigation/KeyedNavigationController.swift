//
//  KeyedNavigationController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 06.01.2021.
//

import UIKit

class KeyedNavigationController<K: Hashable>: UINavigationController {

    // MARK: - Public properties

    private(set) var key: K?

    // MARK: - Public methods

    func setKey(_ key: K) {
        self.key = key
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? KeyedNavigationController<K>,
              object.key != nil,
              key != nil  else { return false }

        return self.key?.hashValue == object.key?.hashValue
    }
}
