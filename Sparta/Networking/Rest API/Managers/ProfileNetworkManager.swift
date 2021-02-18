//
//  ProfileNetworkManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 01.12.2020.
//

import UIKit
import NetworkingModels
import SpartaHelpers
import Networking

class ProfileNetworkManager: BaseNetworkManager {

    // MARK: - Variables private

    private let router = NetworkRouter<ProfileEndPoint>()

    // MARK: - Public methods

    func fetchProfile(completion: @escaping TypeClosure<Swift.Result<ResponseModel<User>, SpartaError>>) {

        router.request(.getProfile) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }

    func updateUser(id: Int, parameters: Parameters, completion: @escaping TypeClosure<Swift.Result<ResponseModel<User>, SpartaError>>) {

        router.request(.updateUser(id: id, parameters: parameters)) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }

    func fetchPhonePrefixes(completion: @escaping TypeClosure<Swift.Result<ResponseModel<List<PhonePrefix>>, SpartaError>>) {

        router.request(.getPhonePrefixes) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }

    func fetchPrimaryTradeAreas(completion: @escaping TypeClosure<Swift.Result<ResponseModel<List<TradeArea>>, SpartaError>>) {

        router.request(.getPrimaryTradeAreas) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }

    func fetchUserRoles(completion: @escaping TypeClosure<Swift.Result<ResponseModel<List<UserRole>>, SpartaError>>) {

        router.request(.getUserRoles) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }

    // arbs

    func fetchArbsFavouritesList(completion: @escaping TypeClosure<Swift.Result<ResponseModel<List<Favourite>>, SpartaError>>) {

        router.request(.getArbsFavouritesList) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }

    func addArbToFavouritesList(userId: Int, code: String, completion: @escaping TypeClosure<Swift.Result<ResponseModel<Favourite>, SpartaError>>) {

        var parameters: Parameters = [:]
        parameters["user"] = userId
        parameters["code"] = code

        router.request(.addArbToFavouritesList(parameters: parameters)) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }

    func deleteArbFromFavouritesList(id: Int, completion: @escaping TypeClosure<Swift.Result<ResponseModel<Favourite>, SpartaError>>) {

        router.request(.deleteArbFromFavouritesList(id: id)) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }
}
