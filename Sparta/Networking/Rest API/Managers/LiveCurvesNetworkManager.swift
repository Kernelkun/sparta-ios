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

    func fetchLiveChartsProducts(completion: @escaping TypeClosure<Swift.Result<ResponseModel<List<LiveCurveProfileProduct>>, SpartaError>>) {
        router.request(.getLiveChartsProducts) { [weak self] data, response, error in
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

    func deletePortfolio(id: Int, completion: @escaping BoolClosure) {
        router.request(.deletePortfolio(id: id)) { _, response, _ in
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func changePortfoliosOrder(orders: [Parameters], completion: @escaping BoolClosure) {
        router.request(.changePortfoliosOrder(parameters: ["order": orders])) { _, response, _ in
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func addProduct(portfolioId: Int, productId: Int, completion: @escaping TypeClosure<Swift.Result<ResponseModel<EmptyResponseModel>, SpartaError>>) {
        router.request(.addProduct(portfolioId: portfolioId, productId: productId)) { [weak self] data, response, error in
            guard let strongSelf = self else { return }

            completion(strongSelf.handleResult(data: data, response: response, error: error))
        }
    }

    func deletePortfolioItem(portfolioId: Int, liveCurveId: Int, completion: @escaping BoolClosure) {
        router.request(.deletePortfolioItem(portfolioId: portfolioId, liveCurveId: liveCurveId)) { _, response, _ in
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func changePortfolioItemsOrder(portfolioId: Int, orders: [Parameters], completion: @escaping BoolClosure) {
        router.request(.changePortfolioOrder(portfolioId: portfolioId, parameters: ["order": orders])) { _, response, _ in
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
