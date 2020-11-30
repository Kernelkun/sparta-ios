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
