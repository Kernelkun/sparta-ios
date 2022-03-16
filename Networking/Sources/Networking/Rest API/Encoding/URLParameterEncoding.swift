//
//  URLParameterEncoding.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 21.08.2020.
//  Copyright © 2020 Developer. All rights reserved.
//

import Foundation
import SpartaHelpers

public struct URLParameterEncoder: ParameterURLEncoder {
    
    public func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        
        guard let url = urlRequest.url else { throw NetworkError.missingURL }
        
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
            
            urlComponents.queryItems = [URLQueryItem]()
            
            for (key, value) in parameters {
                
                var value = value
                if let array = value as? [Int] {
                    value = array.compactMap { $0.toString }.joined(separator: ",")
                } else if let array = value as? [Double] {
                    value = array.compactMap { $0.toString }.joined(separator: ",")
                }
                
                let queryItem = URLQueryItem(name: key,
                                             value: "\(value)"/*.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)*/)
                urlComponents.queryItems?.append(queryItem)
            }
            urlRequest.url = urlComponents.url
        }
        
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8",
                                forHTTPHeaderField: "Content-Type")
        }
    }
}
