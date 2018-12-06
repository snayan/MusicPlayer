//
//  Notification.Name.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/12/6.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation

struct PlayerNotification {
    let totalTimeChanged = Notification.Name.init("playerNotification.totalTimeChanged")
    let currentTimeChanged = Notification.Name.init("playerNotification.currentTimeChanged")
    let statusChanged = Notification.Name.init("playerNotification.statusChanged")
    let songChanged = Notification.Name.init("playerNotification.songChanged")
    let errorOccurred = Notification.Name.init("playerNotification.errorOccurred")
}

extension Notification.Name {
    static let player = PlayerNotification()
}

