//
//  time.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/12/6.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation
import AVFoundation

func timeToFloat(time: CMTime?) -> Float {
    guard let time = time else {
        return 0
    }
    return Float(CMTimeGetSeconds(time))
}

func formartTime(time: Float?) -> String {
    guard let time = time else {
        return "00:00"
    }
    let intTime = Int(time)
    let munite = intTime / 60
    let second = intTime - munite * 60
    let muniteString = munite < 10 ? "0\(munite)" : "\(munite)"
    let secondString = second < 10 ? "0\(second)" : "\(second)"
    return muniteString + ":" + secondString
}
