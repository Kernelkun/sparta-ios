//
//  Array+Unique.swift
//  
//
//  Created by Yaroslav Babalich on 30.09.2021.
//

import Foundation

public extension Array where Element: Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            guard !uniqueValues.contains(item) else { return }
            uniqueValues.append(item)
        }
        return uniqueValues
    }
}
