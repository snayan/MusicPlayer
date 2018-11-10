//
//  MPErrorEnum.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/7.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation

enum MPHttpError: Error {
    
    enum URLError {
        case AnyReason
        case InvalidPath
        case InvalidURL
    }
    
    enum ClientError {
        case AnyReason
        case Forbidden
    }
    
    enum ServerError {
        case AnyReason
        case NotAvailabel
        case BadGateway
        case InvalidMimeType
        case NoResponseData
    }

    case URL(URLError)
    case Client(ClientError)
    case Server(ServerError)
}
