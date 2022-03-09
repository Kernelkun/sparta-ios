//
//  BaseViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 25.11.2020.
//

import UIKit
import Then
import NVActivityIndicatorView

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Public properties
    
    var loader: NVActivityIndicatorView!
    var loadingView = LoadingView()
    
    var isFirstLoad: Bool {
        return enterCount <= 1
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

//    override var shouldAutorotate: Bool { false }
//
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        .all
//    }
    
    // MARK: - Private accessors
    
    private var enterCount: Int = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationItem.backButtonTitle = "Back"
        
        setupUI()

        view.backgroundColor = UIColor.mainBackground

        setupKeyboardEvents()

        //
        // Tap recognizer for dismissing the keyboard on empty space tap.

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(Self.endEditing)).then {
//            $0.cancelsTouchesInView = false
            $0.delegate = self
        }

        view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        defer { enterCount += 1 }
    }
    
    // MARK: - Public methods
    
    func navigationBar(hide: Bool) {
        navigationController?.isNavigationBarHidden = hide
    }

    func loadingView(isAnimating: Bool) {
        if isAnimating {

            loadingView.alpha = 0
            view.addSubview(loadingView) {
                $0.edges.equalToSuperview()
            }

            UIView.animate(withDuration: 0.2) {
                self.loadingView.alpha = 1.0
            }
        } else {

            UIView.animate(withDuration: 0.2) {
                self.loadingView.alpha = 0.0
            } completion: { _ in
                self.loadingView.removeFromSuperview()
            }
        }
    }

    // MARK: - Keyboard Management

    func shouldEndEditingByTap() -> Bool { true }

    @objc
    private func endEditing() {
        guard shouldEndEditingByTap() else { return }

        view.endEditing(true)
    }

    private func setupKeyboardEvents() {

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adjustKeyboardOffset(notification:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adjustKeyboardOffset(notification:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
    }

    @objc
    private func adjustKeyboardOffset(notification: Notification) {

        guard
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
            let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            else { return }

        let presented = notification.name != UIResponder.keyboardWillHideNotification
        updateUIForKeyboardPresented(presented, frame: frame)

        UIView.animate(
            withDuration: duration, delay: 0,
            options: [UIView.AnimationOptions(rawValue: curve.uintValue << 16), .beginFromCurrentState],
            animations: { self.view.layoutIfNeeded() },
            completion: nil
        )
    }

    func updateUIForKeyboardPresented(_ presented: Bool, frame: CGRect) {
        print("Need to override this method")
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl)
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        
        // loader
        
        loader = NVActivityIndicatorView(frame: .zero).then {
            $0.type = .lineScale
            $0.color = .controlTintActive
            
            addSubview($0) {
                $0.centerY.equalToSuperview().multipliedBy(0.7)
                $0.centerX.equalToSuperview()
                $0.width.height.equalTo(40)
            }
        }
        
        // navigation
        
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = .clear
    }
}
