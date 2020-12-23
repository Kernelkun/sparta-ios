//
//  EndPointType+Token.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 23.12.2020.
//

import Foundation
import Networking

extension EndPointType {
    var headersWithToken: HTTPHeaders {
        return ["Authorization": "Bearer \(App.instance.token ?? "")"]
    }
}
