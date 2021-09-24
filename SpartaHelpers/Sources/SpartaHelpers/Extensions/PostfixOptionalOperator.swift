//
//  PostfixOptionalOperator.swift
//  
//
//  Created by Yaroslav Babalich on 21.09.2021.
//

import Foundation

extension Optional {
    public func required() -> Wrapped {
        return self!
    }
}
