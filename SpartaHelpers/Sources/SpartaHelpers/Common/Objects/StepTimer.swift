//
//  StepTimer.swift
//  
//
//  Created by Yaroslav Babalich on 04.03.2021.
//

import Foundation

public protocol TimerDelegate: AnyObject {
    func timerDidChangeStepsCount(_ stepsCount: Int, isFinished: Bool)
}

public protocol TimerProtocol {
    var delegate: TimerDelegate? { get set }
    var stepsCount: Int { get }

    /// To start timer use this method
    func start(interval: TimeInterval, duration: TimeInterval)

    /// To pause timer use this method
    func pause()

    /// To resume timer use this method
    func resume()

    /// To finish timer use this method
    func stop()
}

open class StepTimer: TimerProtocol {
    // MARK: - Public properties

    public weak var delegate: TimerDelegate?
    public private(set) var stepsCount: Int = 0

    // MARK: - Private properties

    private var timer: Timer?

    private var timeInterval: TimeInterval = 0
    private var duration: TimeInterval = 0

    private var isPaused: Bool = false

    // MARK: - Initializers

    public init() { }

    // MARK: - Public methods

    public func start(interval: TimeInterval, duration: TimeInterval = .infinity) {
        stepsCount = 0
        self.timeInterval = interval
        self.duration = duration
        self.isPaused = false

        stop()

        timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                     target: self,
                                     selector: #selector(timerStep),
                                     userInfo: nil,
                                     repeats: true)

        delegate?.timerDidChangeStepsCount(stepsCount, isFinished: false)
    }

    public func pause() {
        guard let timer = timer else { return }

        isPaused = true

        if timer.isValid {
            timer.invalidate()
            self.timer = nil
        }
    }

    public func resume() {
        guard isPaused else { return }

        self.timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                          target: self,
                                          selector: #selector(timerStep),
                                          userInfo: nil,
                                          repeats: true)
    }

    public func stop() {
        guard let timer = timer else { return }

        if timer.isValid {
            timer.invalidate()
            self.timer = nil
        }
    }

    // MARK: - Private methods

    @objc
    private func timerStep() {
        stepsCount += 1

        if duration != .infinity {
            let totalSteps = duration / timeInterval

            if TimeInterval(stepsCount) >= totalSteps {
                delegate?.timerDidChangeStepsCount(stepsCount, isFinished: true)
                stop()
            } else {
                delegate?.timerDidChangeStepsCount(stepsCount, isFinished: false)
            }
        } else {
            delegate?.timerDidChangeStepsCount(stepsCount, isFinished: false)
        }
    }
}
