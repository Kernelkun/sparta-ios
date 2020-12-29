//
//  BaseVMViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 27.11.2020.
//

import UIKit

protocol BaseViewModel: class {

    associatedtype Controller
    var delegate: Controller? { get set }
}

class BaseVMViewController<Model: NSObject & BaseViewModel>: BaseViewController, UIGestureRecognizerDelegate {

    // MARK: - Public properties

    private(set) var viewModel: Model! {
        didSet { viewModel.delegate = self as? Model.Controller }
    }

    var loadingView = LoadingView()

    // MARK: - Initializers

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        viewModel = Model()
        viewModel.delegate = self as? Model.Controller
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.mainBackground

//        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        setupKeyboardEvents()

        //
        // Tap recognizer for dismissing the keyboard on empty space tap.

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(Self.endEditing)).then {
//            $0.cancelsTouchesInView = false
            $0.delegate = self
        }

        view.addGestureRecognizer(tapRecognizer)
    }

    // MARK: - Public methods

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

    @objc private func adjustKeyboardOffset(notification: Notification) {

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
}
