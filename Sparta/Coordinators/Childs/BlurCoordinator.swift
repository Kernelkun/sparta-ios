//
//  BlurCoordinator.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import UIKit
import NVActivityIndicatorView

class BlurCoordinator: Coordinator {

    //
    // MARK: - Private Stuff

    private let window: UIWindow
    private var shouldForce: Bool = false

    private var displayString: String? {
        didSet {

            guard let string = displayString?.trimmed.nullable else {
                loadingIndicator.stopAnimating()
                statusLabel.text = nil
                return
            }

            loadingIndicator.startAnimating()
            statusLabel.text = string
            statusLabel.sizeToFit()
        }
    }

    //
    // MARK: - IB Outlets

    private let effect = UIBlurEffect(style: .regular)

    private var blurredView: UIView!
    private var visualEffectView: UIVisualEffectView!

    private var stackView: UIStackView!
    private var loadingIndicator: NVActivityIndicatorView!
    private var statusLabel: UILabel!

    //
    // MARK: - Object Lifecycle

    init(window: UIWindow) {

        self.window = window
        window.rootViewController = UIViewController()

        super.init()

        //
        // Blur Effect

        blurredView = UIView().then { v in
            window.addSubview(v) { $0.edges.equalToSuperview() }
        }

        visualEffectView = UIVisualEffectView().then { v in
            v.effect = nil
            blurredView.addSubview(v) { $0.edges.equalToSuperview() }
        }

        //
        // Status Label

        loadingIndicator = NVActivityIndicatorView(frame: .zero).then { v in
            v.type = .lineScale
            v.color = .primaryText
            v.snp.makeConstraints { $0.width.height.equalTo(22) }
        }

        statusLabel = UILabel().then { v in
            v.font = .systemFont(ofSize: 24, weight: .light)
            v.textColor = .primaryText

            v.numberOfLines = 1
            v.textAlignment = .left

            v.setContentCompressionResistancePriority(.required, for: .vertical)
            v.setContentHuggingPriority(.required, for: .vertical)
        }

        stackView = UIStackView().then { v in
            v.distribution = .equalSpacing
            v.spacing = 12
            v.axis = .horizontal
            v.alignment = .center

            v.addArrangedSubview(loadingIndicator)
            v.addArrangedSubview(statusLabel)

            blurredView.addSubview(v) { $0.center.equalToSuperview() }
        }

        //

        subsribeToApplicationStateEvents()
    }

    //
    // MARK: - Appearance Management

    override func start() {
        self.start(forced: false, status: displayString)
    }

    override func finish() {
        self.finish(forced: false)
    }

    func start(forced: Bool, status: String? = nil) {

        if shouldForce == false { shouldForce = forced }
        displayString = status

        guard !isPresented else { return }
        super.start()

        window.makeKeyAndVisible()

        UIView.animate(
            withDuration: 0.2, delay: 0,
            options: [.beginFromCurrentState],
            animations: {
                self.visualEffectView.effect = self.effect
                self.stackView.alpha = 1
            },
            completion: nil
        )
    }

    func finish(forced: Bool) {

        guard shouldForce == false || forced else { return }
        displayString = nil
        shouldForce = false

        guard isPresented else { return }
        super.finish()

        UIView.animate(
            withDuration: 0.2, delay: 0,
            options: [.beginFromCurrentState],
            animations: {
                self.visualEffectView.effect = nil
                self.stackView.alpha = 0
            },
            completion: { _ in if !self.isPresented { self.window.isHidden = true } }
        )
    }
}

private extension BlurCoordinator {

    func subsribeToApplicationStateEvents() {

        NotificationCenter.default.addObserver(
            self, selector: #selector(applicationWillResignActive(_:)),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self, selector: #selector(applicationDidBecomeActive(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc func applicationWillResignActive(_ notification: Notification) {
        start()
    }

    @objc func applicationDidBecomeActive(_ notification: Notification) {
        finish()
    }
}
