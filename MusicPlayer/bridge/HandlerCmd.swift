////
////  HandlerCmd.swift
////  MusicPlayer
////
////  Created by yang.zhang on 2018/12/12.
////  Copyright © 2018 yang.zhang. All rights reserved.
////

struct Handler {
    var cmd: String
    var dataType: Decodable.Type
}

struct NativeHandlerCMD {
    static let configurePage = "configurePage"
}

struct WebHandlerCMD {
    static let onBackEvent = "onBackEvent"
}


