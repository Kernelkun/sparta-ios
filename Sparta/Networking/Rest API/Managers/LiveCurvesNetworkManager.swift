//
//  LiveCurvesNetworkManager.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 14.05.2021.
//

import UIKit
import NetworkingModels
import SpartaHelpers
import Networking

class LiveCurvesNetworkManager: BaseNetworkManager {

    // MARK: - Variables private

    private let router = NetworkRouter<LiveCurvesEndPoint>()

    // MARK: - Public methods

    func fetchLiveCurves(completion: @escaping TypeClosure<Swift.Result<ResponseModel<List<LiveCurve>>, SpartaError>>) {
        router.request(.getLiveCurves) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }

    func fetchPortfolios(completion: @escaping TypeClosure<Swift.Result<ResponseModel<List<LiveCurveProfileCategory>>, SpartaError>>) {
        router.request(.getPortfolios) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }

    func fetchProducts(completion: @escaping TypeClosure<Swift.Result<ResponseModel<List<LiveCurveProfileProduct>>, SpartaError>>) {
        router.request(.getProducts) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }

    func fetchProductGroups(completion: @escaping TypeClosure<Swift.Result<ResponseModel<List<LiveCurveProfileGroup>>, SpartaError>>) {
        router.request(.getProductGroups) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }

    func createPortfolio(name: String, completion: @escaping TypeClosure<Swift.Result<ResponseModel<LiveCurveProfileCategory>, SpartaError>>) {
        router.request(.addPortfolio(name: name)) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }

    func addProduct(portfolioId: Int, productId: Int, completion: @escaping TypeClosure<Swift.Result<ResponseModel<EmptyResponseModel>, SpartaError>>) {
        router.request(.addProduct(portfolioId: portfolioId, productId: productId)) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }
}
