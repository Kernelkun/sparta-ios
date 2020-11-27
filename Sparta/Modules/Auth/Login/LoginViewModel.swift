//
//  LoginViewModel.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 26.11.2020.
//

import Foundation

protocol LoginViewModelDelegate: class {

}

class LoginViewModel: NSObject, BaseViewModel {


    // MARK: - Public properties

    weak var delegate: LoginViewModelDelegate?

}
