//
//  BackendModel.swift
//  
//
//  Created by Yaroslav Babalich on 30.11.2020.
//

import Foundation
import SwiftyJSON

/// The main protocol to confirm for the models coming from the backend.
public protocol BackendModel {

    init(json: JSON)
}

public extension BackendModel {

    /// Syntactic sugar to have an empty model.
    static var empty: Self { Self(json: JSON()) }
}
