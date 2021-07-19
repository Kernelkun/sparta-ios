//
//  HTTPTask.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 21.08.2020.
//  Copyright © 2020 Developer. All rights reserved.
//

import Foundation

public typealias HTTPHeaders = [String: String]
public typealias Parameters = [String: Any]

public enum MimeType: String {
    case imageJPG = "image/jpg"
    case imagePNG = "image/png"
}

public typealias FormDataPatameter = (parameterName: String, data: Data, fileName: String, mimeType: MimeType)

public enum HTTPTask {
    case request
    
    case requestParameters(bodyParameters: Parameters?,
                           bodyEncoding: ParameterEncoding,
                           urlParameters: Parameters?)
    
    case requestParametersAndHeaders(bodyParameters: Parameters?,
                                     bodyEncoding: ParameterEncoding,
                                     urlParameters: Parameters?,
                                     additionHeaders: HTTPHeaders?)

    case requestAnyAndHeaders(bodyParameters: Any?,
                              bodyEncoding: ParameterEncoding,
                              urlParameters: Parameters?,
                              additionHeaders: HTTPHeaders?)
    
    case requestWithFile(file: FormDataPatameter,
                         parameters: Parameters?,
                         additionHeaders: HTTPHeaders?)
}
