//
//  Common.swift
//  
//
//  Created by Yaroslav Babalich on 21.01.2021.
//

import Foundation

public func onMainThread(delay: TimeInterval = 0, _ block: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { block() }
}

public func isAvailableiOS13() -> Bool {
    if #available(iOS 13, *) {
        return true
    } else {
        return false
    }
}

public typealias TypeClosure<T> = (T) -> Void
public typealias EmptyClosure = () -> Void
public typealias StringClosure = TypeClosure<String>
public typealias BoolClosure = TypeClosure<Bool>
public typealias ErrorClosure = TypeClosure<Error?>
