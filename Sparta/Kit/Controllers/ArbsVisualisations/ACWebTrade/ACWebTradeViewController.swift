//
//  ACWebTradeViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 12.04.2022.
//

import UIKit
import WebKit
import SpartaHelpers
import App

protocol ACWebTradeViewDelegate: AnyObject {
    func acWebTradeViewControllerDidChangeContentOffset(_ viewController: ACWebTradeViewController, offset: CGFloat, direction: MovingDirection)
    func acWebTradeViewControllerDidTapOnHLView(_ viewController: ACWebTradeViewController)
    func acWebTradeViewControllerDidChangeOrientation(_ viewController: ACWebTradeViewController, interfaceOrientation: UIInterfaceOrientation)
}

class ACWebTradeViewController: UIViewController {

    // MARK: - Public properties

    weak var delegate: ACWebTradeViewDelegate?

    // MARK: - UI properties

    private var edges: UIEdgeInsets
    private let webView: WKWebView

    private var scrollViewPanGesture: UIPanGestureRecognizer!

    // MARK: - Initializers

    init(edges: UIEdgeInsets) {
        self.edges = edges

        webView = WKWebViewWarmUper.liveChartsWarmUper.dequeue()
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

    // MARK: - Public methods

    func load(configurator: Configurator) {
        var urlComponents = URLComponents(string: Environment.avTradeChartURL)
        urlComponents?.queryItems = [
            URLQueryItem(name: "token", value: App.instance.token),
            URLQueryItem(name: "arbIds", value: "\(configurator.arbIds)"),
            URLQueryItem(name: "dateRange", value: configurator.dateRange.rawValue)
        ]

        if let deliveryWindow = configurator.deliveryWindow {
            let deliveryWindowParam = URLQueryItem(name: "deliveryWindow", value: deliveryWindow)
            urlComponents?.queryItems?.append(deliveryWindowParam)
        }

        if let deliveryMonth = configurator.deliveryMonth {
            let deliveryMonthParam = URLQueryItem(name: "deliveryMonth", value: deliveryMonth)
            urlComponents?.queryItems?.append(deliveryMonthParam)
        }

        guard let urlString = urlComponents?.url else { return }

        var request = URLRequest(url: urlString)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        self.webView.load(request)
    }

    func reloadContent() {
        self.webView.reload()
    }

    func updateEdges(_ edges: UIEdgeInsets) {
        self.edges = edges

        webView.snp.updateConstraints {
            $0.edges.equalTo(edges)
        }
    }

    // MARK: - Private methods

    private func setupUI() {
        view.backgroundColor = .neutral80

        webView.do { webView in

            webView.backgroundColor = .neutral80
            webView.scrollView.backgroundColor = .neutral80
            webView.isOpaque = false

            webView.navigationDelegate = self
            webView.uiDelegate = self

            webView.scrollView.contentInsetAdjustmentBehavior = .never
            webView.scrollView.bounces = false
            webView.scrollView.bouncesZoom = false
            webView.scrollView.isScrollEnabled = false
            webView.scrollView.minimumZoomScale = 1.0
            webView.scrollView.maximumZoomScale = 1.0
            webView.scrollView.panGestureRecognizer.isEnabled = false

            scrollViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
            scrollViewPanGesture.delegate = self
            webView.addGestureRecognizer(scrollViewPanGesture)

            addSubview(webView) {
                $0.edges.equalTo(edges)
            }
        }

        /*_ = TappableView().then { view in

            view.backgroundColor = .clear
            view.onTap { [unowned self] _ in
                self.delegate?.acWebTradeViewControllerDidTapOnHLView(self)
            }

            addSubview(view) {
                $0.left.top.right.equalToSuperview()
                $0.height.equalTo(70)
            }
        }*/
    }

    // MARK: - Events

    @objc
    private func onPan(_ gesture: UIPanGestureRecognizer) {
        let velocity = scrollViewPanGesture.velocity(in: webView)
        let translation = scrollViewPanGesture.translation(in: webView)
        let isVerticalGesture = abs(velocity.y) > abs(velocity.x)

        func scrollAction(direction: MovingDirection) {
            switch gesture.state {
            case .changed:
                let translation = gesture.translation(in: webView)
                gesture.setTranslation(.zero, in: webView)

                if direction == .up {
                    delegate?.acWebTradeViewControllerDidChangeContentOffset(self, offset: translation.y, direction: .up)
                } else if direction == .down {
                    delegate?.acWebTradeViewControllerDidChangeContentOffset(self, offset: translation.y, direction: .down)
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

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard let orientation = UIApplication.interfaceOrientation else { return }

        delegate?.acWebTradeViewControllerDidChangeOrientation(self, interfaceOrientation: orientation)
    }
}

extension ACWebTradeViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

extension ACWebTradeViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("WebView *: didFailProvisionalNavigation: \(error.localizedDescription)")

        if (error as NSError).code == -999 {
            webView.reload()
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WebView *: didFail: \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("WebView *: didFinish")
    }
}

extension ACWebTradeViewController: WKUIDelegate {

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let frame = navigationAction.targetFrame,
           frame.isMainFrame {
            return nil
        }
        self.webView.load(navigationAction.request)
        return nil
    }
}
