//
//  Coordinator.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import UIKit

protocol CoordinatorDelegate: AnyObject {
    func coordinatorDidStart(_ coordinator: Coordinator)
    func coordinatorDidFinish(_ coordinator: Coordinator)
}

protocol CoordinatorProtocol {
    func start()
    func finish()
}

//

class Coordinator: NSObject, CoordinatorProtocol {

    weak var delegate: CoordinatorDelegate?

    var isPresented: Bool = false

    //

    func start() {
        isPresented = true
        delegate?.coordinatorDidStart(self)
    }

    func finish() {
        isPresented = false
        delegate?.coordinatorDidFinish(self)
    }
}
