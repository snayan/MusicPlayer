//
//  PlayerDelegate.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/27.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation
import AVFoundation

protocol PlayerDelegate: class {
    func play(_ player: PlayerManager, totalTimeChanged totalTime: CMTime?) -> Void
    func play(_ player: PlayerManager, currentTimeChanged currentTime: CMTime) -> Void
    func play(_ player: PlayerManager, statusChanged status: PlayerManager.Status) -> Void
    func play(_ player: PlayerManager, withOccureError error: PlayerManager.PlayError) -> Void
    func play(_ player: PlayerManager, songChanged song: MPChannelData.Song?) -> Void
}

extension PlayerDelegate {
    
    func play(_ player: PlayerManager, totalTimeChanged totalTime: CMTime?) -> Void {
        let center = NotificationCenter.default
        let userInfo: [String: Any] = ["song": player.currentSong as Any, "value": totalTime as Any]
        center.post(name: Notification.Name.player.totalTimeChanged, object: nil, userInfo: userInfo)
    }
    
    func play(_ player: PlayerManager, currentTimeChanged currentTime: CMTime) -> Void {
        let center = NotificationCenter.default
        let userInfo: [String: Any] = ["song": player.currentSong as Any, "value": currentTime as Any]
        center.post(name: Notification.Name.player.currentTimeChanged, object: nil, userInfo: userInfo)
    }
    
    func play(_ player: PlayerManager, statusChanged status: PlayerManager.Status) -> Void {
        let center = NotificationCenter.default
        let userInfo: [String: Any] = ["song": player.currentSong as Any, "value": status as Any]
        center.post(name: Notification.Name.player.statusChanged, object: nil, userInfo: userInfo)
    }
    
    func play(_ player: PlayerManager, withOccureError error: PlayerManager.PlayError) -> Void {
        let center = NotificationCenter.default
        let userInfo: [String: Any] = ["song": player.currentSong as Any, "value": error as Any]
        player.pause()
        center.post(name: Notification.Name.player.errorOccurred, object: nil, userInfo: userInfo)
    }
    
    func play(_ player: PlayerManager, songChanged song: MPChannelData.Song?) -> Void {
        let center = NotificationCenter.default
        let userInfo: [String: Any] = ["song": song as Any, "value": song as Any]
        center.post(name: Notification.Name.player.songChanged, object: nil, userInfo: userInfo)
    }

}
