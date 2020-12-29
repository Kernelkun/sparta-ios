//
//  FreightViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 10.12.2020.
//

import UIKit
import Networking
import SwiftyJSON
import NetworkingModels

protocol FreightViewModelDelegate: class {

}

class FreightViewModel: NSObject, BaseViewModel {

    weak var delegate: FreightViewModelDelegate?

    // MARK: - Private properties


    // MARK: - Public methods

    func loadData() {
    }
}
