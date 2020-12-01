//
//  NetworkLogger.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 21.08.2020.
//  Copyright © 2020 Developer. All rights reserved.
//

import Foundation
import NetworkingModels

public class NetworkLogger {
    
    public static func log(request: URLRequest) {
        
        print("\n - - - - - - - - - - OUTGOING - - - - - - - - - - \n")
        defer { print("\n - - - - - - - - - -  END - - - - - - - - - - \n") }
        
        let urlAsString = request.url?.absoluteString ?? ""
        let urlComponents = NSURLComponents(string: urlAsString)
        
        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""
        let path = "\(urlComponents?.path ?? "")"
        let query = "\(urlComponents?.query ?? "")"
        let host = "\(urlComponents?.host ?? "")"
        
        var logOutput = """
                        \(urlAsString) \n\n
                        \(method) \(path)?\(query) HTTP/1.1 \n
                        HOST: \(host)\n
                        """
        for (key,value) in request.allHTTPHeaderFields ?? [:] {
            logOutput += "\(key): \(value) \n"
        }
        if let body = request.httpBody {
            logOutput += "\n \(NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "")"
        }
        
        print(logOutput)
    }
    
    public static func log(response: URLResponse) {}
    
    public static func log(responseData: Data?) {
        
        print("\n - - - - - - - - - - RESPONSE DATA - - - - - - - - - - \n")
        defer { print("\n - - - - - - - - - -  END - - - - - - - - - - \n") }
        
        guard let responseData = responseData else {
            print("NIL")
            return
        }
        
        print(String(data: responseData, encoding: .utf8) ?? "NIL")
    }
    
    public static func log<T: BackendModel>(responseModel: ResponseModel<T>) {
        
        print("\n - - - - - - - - - - RESPONSE MODEL - - - - - - - - - - \n")
        defer { print("\n - - - - - - - - - -  END - - - - - - - - - - \n") }
        
//        if let user = responseModel.model as? UserInfo, let token = user.token {
//            print("- AUTHTOKEN: \(token)")
//        }
        
        print("MESSAGE(Status code): \(responseModel.statusCode)")
        print("MODEL: \(responseModel.model.debugDescription)")
        
    }
}
