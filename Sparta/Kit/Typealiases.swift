//
//  Typealiases.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import Foundation

typealias TypeClosure<T> = (T) -> Void

typealias EmptyClosure = () -> Void
typealias StringClosure = TypeClosure<String>
typealias BoolClosure = TypeClosure<Bool>
typealias ErrorClosure = TypeClosure<Error?>
