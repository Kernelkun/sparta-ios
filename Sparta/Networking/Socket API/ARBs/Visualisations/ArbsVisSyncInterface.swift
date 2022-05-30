//
//  ArbsVisSyncInterface.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 25.03.2022.
//

import Foundation
import NetworkingModels
import App

protocol ArbsVisSyncInterface {

    /// Launch service. To receive any updates need to use this method
    func start(dateRange: Environment.Visualisations.DateRange)
}
