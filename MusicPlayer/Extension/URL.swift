//
//  URL.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/10.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation

extension URL {
    
    static func ATS(string src: String) -> URL? {
        let secureSrc = src.starts(with: "https") ? src : src.replacingOccurrences(of: "http", with: "https")
        return URL(string: secureSrc)
    }
}
