//
//  AsynchronousOperation.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 26.06.2022.
//

import Foundation

protocol AsynchronousOperationDelegate: class {
    func operationDidChangeState(_ newState: AsynchronousOperation.OperationState, operation: AsynchronousOperation)
}

class AsynchronousOperation: Operation {

    /// delegate

    weak var delegate: AsynchronousOperationDelegate?

    /// State for this operation.

    @objc
    enum OperationState: Int {
        case ready
        case executing
        case finished
    }

    /// Concurrent queue for synchronizing access to `state`.

    private let stateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".rw.state", attributes: .concurrent)

    /// Private backing stored property for `state`.

    private var rawState: OperationState = .ready

    /// The state of the operation

    @objc
    private dynamic var state: OperationState {
        get { return stateQueue.sync { rawState } }
        set {
            stateQueue.sync(flags: .barrier) {
                rawState = newValue
                delegate?.operationDidChangeState(newValue, operation: self)
            }
        }
    }

    // MARK: - Various `Operation` properties

    open         override var isReady:        Bool { return state == .ready && super.isReady }
    public final override var isExecuting:    Bool { return state == .executing }
    public final override var isFinished:     Bool { return state == .finished }

    // KVO for dependent properties

    open override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if ["isReady", "isFinished", "isExecuting"].contains(key) {
            return [#keyPath(state)]
        }

        return super.keyPathsForValuesAffectingValue(forKey: key)
    }

    // Start

    public final override func start() {
        if isCancelled {
            finish()
            return
        }

        state = .executing

        main()
    }

    /// Subclasses must implement this to perform their work and they must not call `super`. The default implementation of this function throws an exception.

    open override func main() {
        fatalError("Subclasses must implement `main`.")
    }

    /// Call this function to finish an operation that is currently executing

    public final func finish() {
        if !isFinished { state = .finished }
    }
}

