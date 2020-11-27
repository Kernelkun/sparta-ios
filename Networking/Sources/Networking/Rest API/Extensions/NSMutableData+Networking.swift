//
//  NSMutableData+Networking.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 31.08.2020.
//  Copyright © 2020 Developer. All rights reserved.
//

import Foundation

extension NSMutableData {
    
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
