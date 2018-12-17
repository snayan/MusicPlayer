//
//  CmdHandler.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/12/12.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation
import WebKit

struct Cmd {
    var name: String
    var params: String?
    var callbackId: String?
    init(name: String) {
        self.name = name
    }
}

struct CmdResult: Encodable {
    
    enum Status: String, Encodable {
        case fail
        case success
    }
    
    var status: Status
    var code: Int
    var messge: String?
    var data: String?
    
    func toString() -> String? {
        let encode = JSONEncoder()
        if let result = try? encode.encode(self) {
            return String(data: result, encoding: .utf8)
        }
        return nil
    }
}

typealias CallbackHandler = (_ result: CmdResult) -> Void
typealias CmdHandler = (_ webView: WKWebView, _ params: String?, _ callback: @escaping CallbackHandler) -> Void

struct CmdHandlerDictionary {
    
    var bridge: BridgeProtocol
    private(set) var cmd: [String: CmdHandler] = [:]
    
    func takeSnapshot(_ webView: WKWebView, params: String?, callback: @escaping CallbackHandler) {
        let fileName = "screen.png"
        webView.takeSnapshot(with: nil) { image, error in
            guard let image = image, error == nil else {
                callback(CmdResult(status: .fail, code: -1, messge: error!.localizedDescription, data: nil))
                return
            }
            guard let _ = LocalStore.storeCacheImage(image, fileName: fileName) else {
                callback(CmdResult(status: .fail, code: -2, messge: "Failed to store image", data: nil))
                return
            }
            guard let tmpPicture = Bridge.stringifyTmpImageSRC(fromFileName: fileName) else {
                callback(CmdResult(status: .fail, code: -3, messge: "stringifyTmpImageSRC fail", data: nil))
                return
            }
            callback(CmdResult(status: .success, code: 0, messge: "success", data: tmpPicture))
        }
    }
    
    func configurePage(_ webView: WKWebView, params: String?, callback: @escaping CallbackHandler) {
        guard let params = params else {
            callback(CmdResult(status: .fail, code: -1, messge: "configure must be json object", data: nil))
            return
        }
        
        guard let data = params.data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            callback(CmdResult(status: .fail, code: -2, messge: "JSONSerialization fail", data: nil))
            return
        }
        
        if let title = json?["title"] as? String {
            bridge.setNavigationTitle(title)
        }
        
        callback(CmdResult(status: .success, code: 0, messge: "success", data: "success"))
        
    }
    
    subscript(name: String) -> CmdHandler? {
        return cmd[name]
    }
    
    init(bridge: BridgeProtocol) {
        self.bridge = bridge
        cmd["takeSnapshot"] = takeSnapshot
        cmd["configurePage"] = configurePage
    }
}
