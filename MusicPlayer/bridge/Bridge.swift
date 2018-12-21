//
//  Bridge.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/12/11.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation
import WebKit

class Bridge {
    
    typealias BridgeData = [String: Any]
    typealias RequestCallback = (_: Any?) -> Void
    typealias ResponseCallback = (_: HandlerResult) -> Void
    typealias EvaluateJavasriptHandler = (_: Data?, _ : Error?) -> Void
    typealias RegisterHandlerType = (_ data: BridgeData?, _ callback: ResponseCallback) -> Void
    
    
    let scheme = "https"
    let bridgeInjectHost = "bridgeinject"
    let bridgeMessageHost = "bridgemessage"
    let clientBridgeName = "ClientBridge"
    var fetchMessageCommand: String {
        return "\(clientBridgeName)._fetchQueue()"
    }
    
    var webView: WKWebView
    var scriptURL: URL
    var responseHandlersMap: [String: RegisterHandlerType] = [:]
    var requestHandlersMap: [String: RequestCallback] = [:]
    
    init(webView: WKWebView, scriptURL url: URL) {
        self.webView  = webView
        self.scriptURL = url
    }
    
    func isBridgeMessageURL(_ url: URL?) -> Bool {
        guard let url = url else {
            return false
        }
        return url.scheme == scheme && url.host == bridgeMessageHost
    }
    
    func isBridgeInjectURL(_ url: URL?) -> Bool {
        guard let url = url else {
            return false
        }
        return url.scheme == scheme && url.host == bridgeInjectHost
    }
    
    func injectClientBridge(completionHandler handler: EvaluateJavasriptHandler?) {
        if let data = try? Data(contentsOf: scriptURL),
            let code = String(data: data, encoding: .utf8) {
            evaluateJavascript(code, completionHandler: handler)
        } else {
            handler?(nil, BridgeError.injectBridgeError)
        }
    }
    
    func flushMessageQueue() {
        evaluateJavascript(fetchMessageCommand) {
            result, error in
            guard let result = result, error == nil else {
                return
            }
            do {
                let jsonData = try JSONSerialization.jsonObject(with: result, options: [])
                let messages = jsonData as! [BridgeData]
                for message in messages {
                    if let callbackId =  message["callbackId"] as? String {
                        /// webview call native
                        self.resumeWebCallHandlerMessage(RequestMessage(handlerName: message["handlerName"] as? String, data: message["data"] as? BridgeData, callbackId: callbackId))
                        
                    } else if let responseId = message["responseId"] as? String {
                        /// callback after native call web
                        self.resumeNativeCallbackMessage(ResponseMessage(responseData: message["responseData"], responseId: responseId))
                    } else {
                        /// unkwon message
                        self.resumeUnkownMessage(message)
                    }
                }
            } catch {
                debugPrint(error)
            }
        }
    }
    
    func resumeWebCallHandlerMessage(_ message: RequestMessage) {
        guard let name = message.handlerName, let handler = self.responseHandlersMap[name] else {
            debugPrint("unkown handler name")
            return
        }
        handler(message.data) {
            result in
            let responseMessage = ResponseMessage(responseData: result.getData(), responseId: message.callbackId)
            self.sendToNative(responseMessage)
        }
       
    }
    
    func resumeNativeCallbackMessage(_ message: ResponseMessage) {
        guard let responseId = message.responseId else {
            return
        }
        guard let callback = requestHandlersMap[responseId] else {
            return
        }
        callback(message.responseData)
        requestHandlersMap[responseId] = nil
    }
    
    func resumeUnkownMessage(_ message: Any) {
        debugPrint(message)
    }
    
    func sendToNative(_ message: MessageProtocol) {
        do {
            let data = try JSONSerialization.data(withJSONObject: message.serialization(), options: [])
            let result = String(data: data, encoding: .utf8) ?? ""
            evaluateJavascript("\(clientBridgeName)._handlerMessageFromNative('\(result)')", completionHandler: { _,_ in
            })
        } catch {
            debugPrint(error)
        }
    }
    
    func evaluateJavascript(_ code: String, completionHandler handler: EvaluateJavasriptHandler? ) {
        let internalhandler: (_: Any?, _: Error?) -> Void = {
            result, error in
            guard let result = result as? String, error == nil else {
                handler?(nil, error)
                return
            }
            guard let data = result.data(using: .utf8) else {
                handler?(nil, error)
                return
            }
            handler?(data, error)
        }
        if Thread.isMainThread {
            webView.evaluateJavaScript(code, completionHandler: internalhandler)
        } else {
            DispatchQueue.main.async {
                self.webView.evaluateJavaScript(code, completionHandler: internalhandler)
            }
        }
    }
    
    func callHandler(_ name: String) {
        let requestMessage = RequestMessage(handlerName: name, data: nil, callbackId: nil)
        sendToNative(requestMessage)
    }
    
    func callHandler(_ name: String, callback: @escaping RequestCallback) {
        let uuid = UUID().uuidString
        requestHandlersMap[uuid] = callback
        let requestMessage = RequestMessage(handlerName: name, data: nil, callbackId: uuid)
        sendToNative(requestMessage)
    }
    
    func callHandler(_ name: String, data: BridgeData, callback: @escaping RequestCallback) {
        let uuid = UUID().uuidString
        requestHandlersMap[uuid] = callback
        let requestMessage = RequestMessage(handlerName: name, data: data, callbackId: uuid)
        sendToNative(requestMessage)
    }
    
    func registerHandler(_ name: String, executeBlock block: @escaping RegisterHandlerType) {
        responseHandlersMap[name] = block
    }
    
}

protocol MessageProtocol {
    func serialization() -> Bridge.BridgeData
}

extension Bridge {
    
    ///  请求消息包
    struct RequestMessage: MessageProtocol {
        var handlerName: String?
        var data: BridgeData?
        var callbackId: String?
        func serialization() -> BridgeData {
            var result: BridgeData = [:]
            result["handlerName"] = handlerName
            result["data"] = data
            result["callbackId"] = callbackId
            return result
        }
    }
    
    /// 响应消息包
    struct ResponseMessage: MessageProtocol {
        var responseData: Any?
        var responseId: String?
        func serialization() -> BridgeData {
            var result: BridgeData = [:]
            result["responseId"] = responseId ?? ""
            result["responseData"] = responseData ?? ""
            return result
        }
    }
    
    /// native处理之后返回数据格式
    struct HandlerResult {
        
        enum Status {
            case success
            case fail(Int)
        }
        
        var status: Status
        var data: BridgeData?
        
        init(status: Status) {
            self.status = status
        }
        
        func getData() -> BridgeData {
            var result: BridgeData = [:]
            result["data"] = data
            switch status {
            case .success:
                result["status"] = true
            case .fail(let code):
                result["code"] = code
                result["status"] = false
            }
            return result
        }
    }
    
    enum BridgeError: Error {
        case injectBridgeError
        
    }
}

