//
//  ArbsViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.12.2020.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels

protocol ArbsViewModelDelegate: class {

}

class ArbsViewModel: NSObject, BaseViewModel {

    weak var delegate: ArbsViewModelDelegate?

    // MARK: - Private properties


    // MARK: - Public methods

    func loadData() {
    }
}
