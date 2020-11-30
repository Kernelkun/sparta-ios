//
//  HTTPTask.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 21.08.2020.
//  Copyright © 2020 Developer. All rights reserved.
//

import Foundation

typealias HTTPHeaders = [String: String]
typealias Parameters = [String: Any]

enum MimeType: String {
    case imageJPG = "image/jpg"
    case imagePNG = "image/png"
}

typealias FormDataPatameter = (parameterName: String, data: Data, fileName: String, mimeType: MimeType)

enum HTTPTask {
    case request
    
    case requestParameters(bodyParameters: Parameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: Parameters?)
    
    case requestParametersAndHeaders(bodyParameters: Parameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: Parameters?,
        additionHeaders: HTTPHeaders?)
    
    case requestWithFile(file: FormDataPatameter, parameters: Parameters?, additionHeaders: HTTPHeaders?)
}
