//
//  LCWebViewController.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 03.02.2022.
//

import UIKit
import WebKit

class LCWebViewController: UIViewController {

    // MARK: - Private properties

    private var scrollView: UIScrollView!
    private var webView: WKWebView!

    // MARK: - Lifecycle

    override func loadView() {
        super.loadView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Private methods

    private func setupUI() {
        //        let frame = UIScreen.main.bounds
        //
        let configuration = WKWebViewConfiguration()
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        //        configuration.preferences.javaScriptEnabled = true
        //        let urlRaw = Bundle.main.url(forResource: "index", withExtension: "html")
        //


        var urlComponents = URLComponents(string: "http://sparta-review-ios-iframe-page.s3-website-eu-west-1.amazonaws.com/standaloneChart/")
        urlComponents?.queryItems = [
            URLQueryItem(name: "token", value: App.instance.token)
        ]

        let request = URLRequest(url: urlComponents!.url!)
        //
        //        let webView = WKWebView(frame: frame, configuration: configuration)
        //        webView.navigationDelegate = self
        ////        guard let url = urlRaw else {
        ////            print("No file at url")
        ////            return
        ////        }

        scrollView = UIScrollView().then { scrollView in

            scrollView.showsVerticalScrollIndicator = false
            scrollView.delegate = self

            addSubview(scrollView) {
                $0.top.equalToSuperview().offset(topBarHeight + 12)
                $0.left.bottom.right.equalToSuperview()
            }
        }

        let scrollViewContent = UIView().then { view in

            view.backgroundColor = .clear

            scrollView.addSubview(view) {
                $0.left.top.right.equalToSuperview()
                $0.bottom.lessThanOrEqualToSuperview().priority(.high)
                $0.centerX.equalToSuperview()
            }
        }

        let testView = UIView().then { view in

            view.backgroundColor = .red

            scrollViewContent.addSubview(view) {
                $0.top.equalToSuperview()
                $0.left.right.equalToSuperview()
                $0.height.equalTo(150)
            }
        }

        webView = WKWebView()


        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.scrollView.bounces = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.delegate = self
        webView.load(request)

        scrollViewContent.addSubview(webView) {
            $0.top.equalTo(testView.snp.bottom).offset(24)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(700)
        }

        let bottomView = UIView().then { view in

            view.backgroundColor = .yellow

            scrollViewContent.addSubview(view) {
                $0.top.equalTo(webView.snp.bottom).offset(24)
                $0.left.right.equalToSuperview()
                $0.height.equalTo(150)
                $0.bottom.equalToSuperview()
            }
        }
    }
}

extension LCWebViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let yOffset = scrollView.contentOffset.y
//
//        let screenHeight = UIScreen.main.bounds.height
//        let scrollViewContentHeight: CGFloat = 1100
//
//        if scrollView == self.scrollView {
//            if yOffset >= scrollViewContentHeight - screenHeight {
//                self.scrollView.isScrollEnabled = false
//                webView.scrollView.isScrollEnabled = true
//            }
//        }
//
//        if scrollView == self.webView.scrollView {
//            if yOffset <= 0 {
//                self.scrollView.isScrollEnabled = true
//                webView.scrollView.isScrollEnabled = false
//            }
//        }
    }
}

extension LCWebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}

extension LCWebViewController: WKUIDelegate {

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let frame = navigationAction.targetFrame,
           frame.isMainFrame {
            return nil
        }
        webView.load(navigationAction.request)
        return nil
    }
}
