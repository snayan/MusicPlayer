//
//  Bridge.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/12/11.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation
import WebKit

protocol BridgeProtocol {
    var controller: UIViewController { get }
    func setNavigationTitle(_ title: String) -> Void
    func setNavigationRightItem(_ item: UIBarButtonItem) -> Void
}

extension BridgeProtocol {
    func setNavigationTitle(_ title: String) {
        controller.navigationItem.title = title
    }
    func setNavigationRightItem(_ item: UIBarButtonItem) -> Void {
        controller.navigationItem.rightBarButtonItem = item
    }
}

class Bridge: NSObject, BridgeProtocol, WKURLSchemeHandler {
    
    unowned let controller: UIViewController
    private var contextCode: String!
    private(set) var isLoaded: Bool = false
    private(set) var isInited: Bool = false
    private lazy var cmdHandlerDictionary: CmdHandlerDictionary = { CmdHandlerDictionary(bridge: self) }()
    
    init?(url: URL, controller: UIViewController) {
        do {
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            guard let content = String(data: data, encoding: .utf8)  else {
                throw Bridge.ErrorType.nilOfJavaScriptContent
            }
            contextCode = content
            isLoaded = true
            self.controller = controller
        } catch {
            return nil
        }
    }
    
    private func handlerMessage(_ webView: WKWebView, task urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url, url.pathComponents.count == 3, url.pathComponents[1] == "callHandler"  else {
            return
        }
        let handlerName = url.pathComponents[2]
        if let cmd = generateCmd(withName: handlerName, fromQuery: url.query), let cmdHandler = cmdHandlerDictionary[cmd.name] {
            cmdHandler(webView, cmd.params) { result in
                if let callbackId = cmd.callbackId {
                    let callbackData = result.toString() ?? "null";
                    self.evaluateJavaScript(webView, contentOf: Bridge.invokeMesageCallback(callbackId, callbackData), completionHandler: nil)
                }
                guard result.status == .success else {
                    urlSchemeTask.didFailWithError(Bridge.ErrorType.executeCommandError)
                    return
                }
                let res = URLResponse(url: urlSchemeTask.request.url!, mimeType: "text/html", expectedContentLength: -1, textEncodingName: nil)
                urlSchemeTask.didReceive(res)
                urlSchemeTask.didFinish()
            }
        }
    }
    
    private func handlerImage(_ webView: WKWebView, task urlSchemeTask: WKURLSchemeTask) {
        if let path = urlSchemeTask.request.url?.lastPathComponent {
            guard let fileName = Bridge.parseTmpImageURL(fromEncodedString: path) else {
                urlSchemeTask.didFailWithError(UIImage.ErrorType.invalidURL)
                return
            }
            guard let image = LocalStore.getCacheImage(fileName: fileName)?.pngData() else {
                urlSchemeTask.didFailWithError(Bridge.ErrorType.executeCommandError)
                return
            }
            let res = URLResponse(url: urlSchemeTask.request.url!, mimeType: "image/png", expectedContentLength: image.count, textEncodingName: nil)
            urlSchemeTask.didReceive(res)
            urlSchemeTask.didReceive(image)
            urlSchemeTask.didFinish()
        }
    }
    
    private func  evaluateJavaScript(_ webView: WKWebView, contentOf code: String, completionHandler handler: ((_: Any?, _: Error?) -> Void)?) {
        let completionHandler:(_: Any?, _: Error?) -> Void = {
            data, error in
            if let error = error {
                debugPrint(error)
            }
            handler?(data, error)
        }
        if Thread.isMainThread {
            webView.evaluateJavaScript(code, completionHandler: completionHandler)
        } else {
            DispatchQueue.main.async {
                webView.evaluateJavaScript(code, completionHandler: completionHandler)
            }
        }
    }
    
    private func generateCmd(withName name: String, fromQuery query: String?) -> Cmd? {
        var cmd = Cmd(name: name)
        if let query = query {
            query.split(separator: "&").forEach { item in
                let component = item.split(separator: "=")
                if component.count > 1 {
                    if component[0] == "callbackId" {
                        cmd.callbackId = String(component[1])
                    }
                    if component[0] == "params" {
                        cmd.params = String(component[1]).removingPercentEncoding
                    }
                }
            }
        }
        return cmd
    }
    
    func initialize(_ webView: WKWebView, completion handler: @escaping (_: Bool, _: Error?) -> Void) {
        guard isLoaded else {
            handler(false, ErrorType.notLoaded)
            return
        }
        
        evaluateJavaScript(webView, contentOf: contextCode) { _, error in
            guard error == nil else {
                handler(false, ErrorType.executeJavaScriptError)
                return
            }
            self.isInited = true
        }
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let host = urlSchemeTask.request.url?.host else {
            return
        }
        if host == Bridge.bridgeHost {
            if Thread.isMainThread {
                handlerMessage(webView, task: urlSchemeTask)
                return
            }
            DispatchQueue.main.async {
                self.handlerMessage(webView, task: urlSchemeTask)
            }
        } else if host == Bridge.imageHost {
            handlerImage(webView, task: urlSchemeTask)
        }
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {

    }
    
}

extension Bridge {
    enum ErrorType: Error {
        case notLoaded
        case notFoundJavaScriptFile
        case nilOfJavaScriptContent
        case executeJavaScriptError
        case executeCommandError
    }
    enum RegisterEvent: String {
        case onBackClickEvent
    }
}

extension Bridge {
    static let scheme = "mpwvscm"
    static let bridgeHost = "_mpwvhost_"
    static let imageHost = "image"
    static private let bridgeName = "$$mp$$bridge$$"
    
    static private var consumeJavaScriptMessage: String = {
        return "\(bridgeName)._intel_helper_._nativeConsumeMessage()"
    }()
    
    static private var invokeMesageCallback: (_ id: String, _ data: String) -> String = {
        id, data in
        return "\(bridgeName)._intel_helper_._invokeCallback('\(id)','\(data)')"
    }
    
    static private var invokeRegisterHandler: (_ name: String, _ data: String) -> String = {
        name, data in
        return "\(bridgeName)._intel_helper_._invokeRegisterHandler('\(name)','\(data)')"
    }
    
    static func stringifyTmpImageSRC(fromFileName name: String) -> String? {
        let fullPath = name + "_" + String(Date().timeIntervalSince1970).suffix(5)
        guard let url = fullPath.data(using: .utf8)?.base64EncodedString() else {
            return nil
        }
        return scheme + "://image/" + url
    }
    
    static func parseTmpImageURL(fromEncodedString string: String?) -> String? {
        guard let string = string else {
            return nil
        }
        guard let data = Data(base64Encoded: string), let decodedString = String(data: data, encoding: .utf8) else {
            return nil
        }
        var fileName: String.SubSequence = decodedString[...]
        if let last = decodedString.lastIndex(of: "_") {
            fileName = fileName[...decodedString.index(before: last)]
        }
        return String(fileName)
    }
    
    
    func doRegisterHandler(_ webView: WKWebView, name: RegisterEvent ,params: String, completionHandler handler: ((Any?, Error?) -> Void)?) {
        evaluateJavaScript(webView, contentOf: Bridge.invokeRegisterHandler(name.rawValue, params), completionHandler: handler)
    }

}
