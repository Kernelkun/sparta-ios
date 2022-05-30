//
//  Identifiable.swift
//  
//
//  Created by Yaroslav Babalich on 28.01.2021.
//

import Foundation

public protocol IdentifiableItem: Equatable {
    associatedtype ID: Hashable

    var identifier: ID { get }
}

public struct Identifier<T: Hashable>: IdentifiableItem {
    public typealias ID = T

    // MARK: - Private properties

    public let identifier: T

    // MARK: - Intializers

    public init(id: T) {
        self.identifier = id
    }
}
