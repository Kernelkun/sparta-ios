//
//  WebViewWarmuper.swift
//  Sparta
//
//  Created by Yaroslav Babalich on 18.02.2022.
//

import WebKit
import UIKit
import App

public protocol WarmUpable {
    func warmUp()
}

open class WarmUper<Object: WarmUpable> {

    private let creationClosure: () -> Object
    private var warmedUpObjects: [Object] = []
    public var numberOfWamedUpObjects: Int = 5 {
        didSet {
            prepare()
        }
    }

    public init(creationClosure: @escaping () -> Object) {
        self.creationClosure = creationClosure
        prepare()
    }

    public func prepare() {
        while warmedUpObjects.count < numberOfWamedUpObjects {
            let object = creationClosure()
            object.warmUp()
            warmedUpObjects.append(object)
        }
    }

    private func createObjectAndWarmUp() -> Object {
        let object = creationClosure()
        object.warmUp()
        return object
    }

    public func dequeue() -> Object {
        let warmedUpObject: Object
        if let object = warmedUpObjects.first {
            warmedUpObjects.removeFirst()
            warmedUpObject = object
        } else {
            warmedUpObject = createObjectAndWarmUp()
        }
        prepare()
        return warmedUpObject
    }
}

extension WKWebView: WarmUpable {
    public func warmUp() {
        load(URLRequest(url: Environment.liveChartURL.forcedURL))
    }
}

public typealias WKWebViewWarmUper = WarmUper<WKWebView>

public extension WarmUper where Object == WKWebView {
    static let shared = WKWebViewWarmUper(creationClosure: {
        WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    })

    static var liveChartsWarmUper: WKWebViewWarmUper = {
        // Disable zoom in web view
        let source: String = "var meta = document.createElement('meta');" +
        "meta.name = 'viewport';" +
        "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
        "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);"
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)

        let contentController = WKUserContentController()
        contentController.addUserScript(script)

        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = contentController

        return WKWebViewWarmUper { () -> WKWebView in
            let configuration = WKWebViewConfiguration()
            return WKWebView(frame: .zero, configuration: webViewConfiguration)
        }
    }()
}
