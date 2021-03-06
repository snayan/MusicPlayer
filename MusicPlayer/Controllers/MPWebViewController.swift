//
//  MPWebViewController.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/12/8.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

class MPWebViewController: UIViewController {
    
    var src: String?
    var bridge: Bridge?
    var webView: WKWebView!
    var isShowProgress: Bool = false
    lazy var userContentController: WKUserContentController = {
       [unowned self] in
        let userContentController = WKUserContentController()
        let userSctipt = WKUserScript(source: "window.aaa = 1", injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: true)
        userContentController.addUserScript(userSctipt)
        userContentController.add(MessageHandler(), name: "test")
        return userContentController
    }()
    lazy var configuration: WKWebViewConfiguration = {
        [unowned self] in
        var configuration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent = "MusicPlayer"
        configuration.ignoresViewportScaleLimits = false
        configuration.suppressesIncrementalRendering = false
        configuration.mediaTypesRequiringUserActionForPlayback = []
//        configuration.userContentController = userContentController
        return configuration
    }()
    lazy var progressView: UIProgressView = {
        [unowned self] in
        let progress = UIProgressView(progressViewStyle: .default)
        progress.trackTintColor = UIColor.white
        progress.progressTintColor = UIColor(named: "themeColor")
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    lazy var backButton: UIBarButtonItem = {
        [unowned self] in
        var button = UIBarButtonItem(image: UIImage(named: "backArrowIcon"), style: UIBarButtonItem.Style.done, target: self, action: #selector(MPWebViewController.handleBackTap))
        return button
    }()
    var navigationBarBarTintColor: UIColor?
    var navigationBarTintColor: UIColor?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(src: String?) {
        super.init(nibName: nil, bundle: nil)
        self.src = src
    }

    override func loadView() {
        
        // init webView
        if !WKWebView.handlesURLScheme(ImageBridge.scheme) {
            configuration.setURLSchemeHandler(ImageBridge(), forURLScheme: ImageBridge.scheme)
        }
        webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.scrollView.backgroundColor = UIColor(named: "bgColor")
        webView.uiDelegate = self
        webView.navigationDelegate = self
        // 模拟浏览器中打开
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1"
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        
        // init bridge
        if let bridgeScriptPath = Bundle.main.path(forResource: "bridge", ofType: "js") {
            self.bridge = Bridge(webView: webView, scriptURL: URL(fileURLWithPath: bridgeScriptPath))
        }
        
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(progressView)
        progressView.snp.makeConstraints{make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(2)
        }
        
        navigationItem.leftBarButtonItem = backButton
        
        registerHandlerForWeb()

//        let url = URL(string: "http://localhost:9005/")
//        let request = URLRequest(url: url!)
//        self.webView.load(request)
        if let src = self.src, let url = URL(string: src) {
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationBarBarTintColor = navigationController?.navigationBar.barTintColor
        navigationBarTintColor = navigationController?.navigationBar.tintColor
        navigationController?.navigationBar.barTintColor = nil
        navigationController?.navigationBar.tintColor = UIColor(named: "themeColor")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = navigationBarBarTintColor
        navigationController?.navigationBar.tintColor = navigationBarTintColor
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            if webView.estimatedProgress == 1 {
                showProgress(show: false)
            }
            return
        } else if keyPath == #keyPath(WKWebView.title) {
            navigationItem.title = webView.title
            return
        }
        super.observeValue(forKeyPath: keyPath, of: object, change:change, context: context)
        return
    }
    
    @objc private func handleBackTap() {
        if let bridge = self.bridge {
            bridge.callHandler(WebHandlerCMD.onBackEvent) {
                data in
                guard let pop = (data ?? true) as? Bool else {
                    return
                }
                if pop {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func showProgress(show: Bool) {
        guard show != isShowProgress else {
            return
        }
        isShowProgress = show
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            [unowned self] in
            self.progressView.alpha = show ? 1 : 0
            }, completion: nil)
    }
    
    private func handlerBridgeError(_ error: Error?) {
        if let error = error {
            self.showErrorMessagAlter(error: error)
        } else {
            self.showErrorMessagAlter(error: "bridge error!")
        }
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
}

extension MPWebViewController {
    
    func registerHandlerForWeb() {
        
        /// register configure page
        bridge?.registerHandler(NativeHandlerCMD.configurePage) {
            data, callback in
            if let data = data, let title = data["title"] as? String {
                self.title = title
            }
            callback(Bridge.HandlerResult(status: .success))
        }
        
        /// register takeSnapshot
        bridge?.registerHandler(NativeHandlerCMD.takeSnapshot) {
            _, callback in
            self.webView.takeSnapshot(with: nil) {
                image, error in
                let fileName = "snapshot"
                guard let image = image, error == nil else {
                    callback(Bridge.HandlerResult(status: .fail(-1)))
                    return
                }
                
                guard let _ = LocalStore.storeCacheImage(image, fileName: fileName) else {
                    callback(Bridge.HandlerResult(status: .fail(-2)))
                    return
                }
                
                guard let src = ImageBridge.generateSRC(fileName: fileName) else {
                    callback(Bridge.HandlerResult(status: .fail(-3)))
                    return
                }
                var result = Bridge.HandlerResult(status: .success)
                result.data = ["path": src]
                callback(result)
            }
        }
        
    }
}

extension MPWebViewController: WKUIDelegate {
    func webViewDidClose(_ webView: WKWebView) {
        navigationController?.popViewController(animated: true)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        showAlter(title: nil, message: message, configurateAction: {
            return [UIAlertAction(title: "确定", style: .default, handler: nil)]
        }, completion: nil)
        completionHandler()
    }
}

extension MPWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showProgress(show: true)
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showProgress(show: false)
        debugPrint(error)
        showErrorMessagAlter(error: error)
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//        showErrorMessagAlter(error: error)
         debugPrint(error)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        showProgress(show: false)
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard webView == self.webView,
            let bridge = self.bridge,
            let url = navigationAction.request.url
        else {
            decisionHandler(.allow)
            return
        }
        if bridge.isBridgeInjectURL(url) {
            bridge.injectClientBridge(completionHandler: nil)
            decisionHandler(.cancel)
        } else if bridge.isBridgeMessageURL(url) {
            bridge.flushMessageQueue()
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        showErrorWebPageAlter(retryHandler: {
            self.webView.reload()
        }, backHandler: {
            self.handleBackTap()
        })
    }
}

