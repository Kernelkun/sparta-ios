//
//  LiveCurvesViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.12.2020.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels

protocol LiveCurvesViewModelDelegate: class {

}

class LiveCurvesViewModel: NSObject, BaseViewModel {

    weak var delegate: LiveCurvesViewModelDelegate?

    // MARK: - Private properties


    // MARK: - Public methods

    func loadData() {
    }
}
