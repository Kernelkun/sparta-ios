//
//  CellAnimateOperation.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.06.2022.
//

import UIKit
import SpartaHelpers

class CellAnimateOperation: AsynchronousOperation {

    // MARK: - Private properties

    private let duration: Double
    private let delay: Double
    private let completion: EmptyClosure

    // MARK: - Initializers

    init(duration: Double, delay: Double, completion: @escaping EmptyClosure) {
        self.duration = duration
        self.delay = delay
        self.completion = completion

        super.init()
    }

    override func cancel() {
        super.cancel()
    }

    override func main() {
        onMainThread {
            UIView.animateKeyframes(
                withDuration: self.duration,
                delay: self.delay,
                options: [.calculationModeLinear, .allowUserInteraction]
            ) {
                self.completion()
            } completion: { _ in
                self.finish()
            }
        }
    }
}
