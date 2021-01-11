//
//  DelayObject.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 11.01.2021.
//

import Foundation
import SpartaHelpers

class DelayObject {

    // MARK: - Variables private

    private var _timer: Timer?
    private let interval: TimeInterval

    // MARK: - Initialiezers
    init(delayInterval: TimeInterval) {
        interval = delayInterval
    }

    // MARK: - Public methods
    func addOperation(completion: @escaping EmptyClosure) {
        stopAllOperations()

        _timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false, block: { _ in
            completion()
        })
    }

    func stopAllOperations() {
        _timer?.invalidate()
    }
}
