//
//  SpartaHelpers.swift
//  
//
//  Created by Yaroslav Babalich on 30.11.2020.
//

import Foundation

public typealias TypeClosure<T> = (T) -> Void
public typealias EmptyClosure = () -> Void
public typealias StringClosure = TypeClosure<String>
public typealias BoolClosure = TypeClosure<Bool>
public typealias ErrorClosure = TypeClosure<Error?>

// Given a value to round and a factor to round to,
// round the value to the nearest multiple of that factor.
public func round(_ value: Double, toNearest: Double) -> Double {
    return round(value / toNearest) * toNearest
}

// Given a value to round and a factor to round to,
// round the value DOWN to the largest previous multiple
// of that factor.
public func roundDown(_ value: Double, toNearest: Double) -> Double {
    return floor(value / toNearest) * toNearest
}

// Given a value to round and a factor to round to,
// round the value DOWN to the largest previous multiple
// of that factor.
public func roundUp(_ value: Double, toNearest: Double) -> Double {
    return ceil(value / toNearest) * toNearest
}
