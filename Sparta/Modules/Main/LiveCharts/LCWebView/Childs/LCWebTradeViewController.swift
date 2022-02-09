//
//  LCWebTradeViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 09.02.2022.
//

import UIKit
import WebKit

protocol LCWebTradeViewDelegate: AnyObject {
    func lcWebTradeViewControllerDidChangeContentOffset(_ viewController: LCWebTradeViewController, offset: CGFloat, direction: MovingDirection)
}

class LCWebTradeViewController: UIViewController {

    // MARK: - Public properties

    weak var delegate: LCWebTradeViewDelegate?

    // MARK: - UI properties

    private let webView: WKWebView

    // MARK: - Initializers

    init() {
        webView = WKWebView()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(#function)
    }

    // MARK: - Lifecycle

    override func loadView() {
        self.view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Private methods

    private func setupUI() {

        let configuration = WKWebViewConfiguration()
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        var urlComponents = URLComponents(string: "http://sparta-review-ios-iframe-page.s3-website-eu-west-1.amazonaws.com/standaloneChart/")
        urlComponents?.queryItems = [
            URLQueryItem(name: "token", value: App.instance.token)
        ]

        let request = URLRequest(url: urlComponents!.url!)

        webView.do { webView in

            webView.navigationDelegate = self
            webView.uiDelegate = self

            webView.scrollView.bounces = false
            webView.scrollView.isScrollEnabled = true
            webView.scrollView.minimumZoomScale = 1.0
            webView.scrollView.maximumZoomScale = 1.0
            webView.scrollView.panGestureRecognizer.isEnabled = false
            webView.load(request)

            let scrollViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
            scrollViewPanGesture.delegate = self
            webView.scrollView.addGestureRecognizer(scrollViewPanGesture)
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
