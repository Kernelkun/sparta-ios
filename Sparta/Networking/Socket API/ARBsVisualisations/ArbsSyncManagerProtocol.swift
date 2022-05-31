//
//  ArbsVSyncManagerProtocol.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 02.11.2021.
//

import Foundation
import NetworkingModels

protocol ArbsVSyncManagerProtocol {
    /// Launch service. To receive any updates need to use this method
    func start()
}
