//
//  ImageBridge.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/12/23.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation
import WebKit

class ImageBridge: NSObject ,WKURLSchemeHandler {
    
    static let scheme = "mpis"
    static let host = "mpih"
    
    static func isImageRequest(_ request: URLRequest) -> Bool {
        guard let url = request.url else {
            return false
        }
        return url.scheme == scheme && url.host == host
    }
    
    static func generateSRC(fileName: String) -> String? {
        let random = UUID().uuidString.suffix(10).padding(toLength: 10, withPad: "0", startingAt: 0)
        let rawValue = "\(random)\(fileName)"
        guard let data = rawValue.data(using: .utf8) else {
            return nil
        }
        return "\(scheme)://\(host)/\(data.base64EncodedString())"
    }
    
    static func getFileName(_ request: URLRequest) -> String? {
        guard let url = request.url,
            let data = Data(base64Encoded: url.lastPathComponent),
            let decodedFileName = String(data: data, encoding: .utf8),
            decodedFileName.count > 10
            else {
                return nil
        }
        return String(decodedFileName[decodedFileName.index(decodedFileName.startIndex, offsetBy: 10)...])
    }
    
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard ImageBridge.isImageRequest(urlSchemeTask.request) else {
            return
        }
        guard let fileName = ImageBridge.getFileName(urlSchemeTask.request) else {
            urlSchemeTask.didFailWithError(ImageBridge.ErrorType.canNotFoundFileName)
            return
        }
        
        guard let image = LocalStore.getCacheImage(fileName: fileName), let data = image.pngData() else {
            urlSchemeTask.didFailWithError(ImageBridge.ErrorType.canNotFoundImage)
            return
        }
        let res = URLResponse(url: urlSchemeTask.request.url!, mimeType: "image/png", expectedContentLength: data.count, textEncodingName: nil)
        urlSchemeTask.didReceive(res)
        urlSchemeTask.didReceive(data)
        urlSchemeTask.didFinish()
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        
    }
}

extension ImageBridge {
    enum ErrorType: Error {
        case canNotFoundFileName
        case canNotFoundImage
    }
    
}
