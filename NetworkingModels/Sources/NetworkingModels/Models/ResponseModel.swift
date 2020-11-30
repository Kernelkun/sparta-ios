//
//  ResponseModel.swift
//  
//
//  Created by Yaroslav Babalich on 30.11.2020.
//

import SwiftyJSON

public class ResponseModel<T: BackendModel> {

    // MARK: - Public accessors

    public let statusCode: Int?
    public let model: T?

    // MARK: - Initializers

    public init(json: JSON, modelPrimaryKey: String? = nil) {
        self.statusCode = json["statusCode"].int

        if let modelPrimaryKey = modelPrimaryKey {
            if json[modelPrimaryKey] != JSON.null {
                model = T(json: json[modelPrimaryKey])
            } else { model = nil }
        } else {
            model = T(json: json)
        }
    }
}

public class List<T: BackendModel>: BackendModel {

    // MARK: - Public accessors

    public let list: [T]

    // MARK: - Initializers

    public required init(json: JSON) {
        list = json.arrayValue.map { T(json: $0) }
    }
}
