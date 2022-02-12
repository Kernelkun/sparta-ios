//
//  LCWebTradeViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 09.02.2022.
//

import UIKit
import WebKit
import SpartaHelpers

protocol LCWebTradeViewDelegate: AnyObject {
    func lcWebTradeViewControllerDidChangeContentOffset(_ viewController: LCWebTradeViewController, offset: CGFloat, direction: MovingDirection)
    func lcWebTradeViewControllerDidTapSizeButton(_ viewController: LCWebTradeViewController, buttonType: LCWebTradeViewController.ButtonType)
}

class LCWebTradeViewController: UIViewController {

    // MARK: - Public properties

    weak var delegate: LCWebTradeViewDelegate?

    // MARK: - UI properties

    private let buttonType: ButtonType
    private let webView: WKWebView

    // MARK: - Initializers

    init(buttonType: ButtonType) {
        self.buttonType = buttonType
        webView = WKWebView()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Private methods

    private func setupUI() {

        view.backgroundColor = .neutral80

        let configuration = WKWebViewConfiguration()
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        var urlComponents = URLComponents(string: "http://sparta-review-ios-iframe-page.s3-website-eu-west-1.amazonaws.com/standaloneChart/")
        urlComponents?.queryItems = [
            URLQueryItem(name: "token", value: App.instance.token)
        ]

        let request = URLRequest(url: urlComponents!.url!)

        webView.do { webView in

            webView.backgroundColor = .neutral80

            webView.navigationDelegate = self
            webView.uiDelegate = self

            webView.scrollView.contentInsetAdjustmentBehavior = .never
            webView.scrollView.bounces = false
            webView.scrollView.isScrollEnabled = true
            webView.scrollView.minimumZoomScale = 1.0
            webView.scrollView.maximumZoomScale = 1.0
            webView.scrollView.panGestureRecognizer.isEnabled = false
            webView.load(request)

            let scrollViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
            scrollViewPanGesture.delegate = self
            webView.scrollView.addGestureRecognizer(scrollViewPanGesture)

            addSubview(webView) {
                $0.left.equalTo(view.snp.leftMargin)
                $0.top.right.equalToSuperview()
                $0.bottom.equalTo(view.snp.bottomMargin)
            }
        }

        if buttonType != .none {
            _ = TappableButton().then { button in

                let imageName = buttonType == .collapse ? "ic_chart_collapse" : "ic_chart_expand"

                button.backgroundColor = .neutral80
                button.setImage(UIImage(named: imageName), for: .normal)
                button.onTap { [unowned self] _ in
                    delegate?.lcWebTradeViewControllerDidTapSizeButton(self, buttonType: buttonType)
                }

                view.addSubview(button) {
                    $0.size.equalTo(40)
                    $0.bottom.equalToSuperview().offset(-24)
                    $0.right.equalToSuperview().inset(16)
                }
            }
        }
    }

    // MARK: - Events

    @objc
    private func onPan(_ gesture: UIPanGestureRecognizer) {
//        let currentOffset = scrollView.contentOffset.y

        let velocity = webView.scrollView.panGestureRecognizer.velocity(in: webView)
        let translation = webView.scrollView.panGestureRecognizer.translation(in: webView)
        let isVerticalGesture = abs(velocity.y) > abs(velocity.x)


        func scrollAction(direction: MovingDirection) {
            switch gesture.state {
            case .changed:
                let translation = gesture.translation(in: webView)
                gesture.setTranslation(.zero, in: webView)

                if direction == .up {
//                    let newYOffset = currentOffset - translation.y
//                    print(newYOffset)

//                    scrollView.contentOffset = CGPoint(x: 0, y: newYOffset)
                    delegate?.lcWebTradeViewControllerDidChangeContentOffset(self, offset: translation.y, direction: .up)

                } else if direction == .down {
//                    let newYOffset = currentOffset + translation.y
//                    print(newYOffset)

//                    scrollView.contentOffset = CGPoint(x: 0, y: newYOffset)
                    delegate?.lcWebTradeViewControllerDidChangeContentOffset(self, offset: translation.y, direction: .down)
                }

            @unknown default:
                break
            }
        }

        if isVerticalGesture {
            if velocity.y > 0 {
                scrollAction(direction: .down)
            } else {
                scrollAction(direction: .up)
            }
        }
    }
}

extension LCWebTradeViewController {
    enum ButtonType {
        case none
        case expand
        case collapse
    }
}

extension LCWebTradeViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

extension LCWebTradeViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}

extension LCWebTradeViewController: WKUIDelegate {

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let frame = navigationAction.targetFrame,
           frame.isMainFrame {
            return nil
        }
        webView.load(navigationAction.request)
        return nil
    }
}
