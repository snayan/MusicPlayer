//
//  MessageHandler.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/12/23.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation
import WebKit

class MessageHandler: NSObject, WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "test", let data = message.body as? String {
            debugPrint(data)
        }
    }
    
}
