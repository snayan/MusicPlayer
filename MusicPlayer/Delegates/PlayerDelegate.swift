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
    func play(currentSong song: MPChannelData.Song?, totalTimeChanged totalTime: CMTime?) -> Void
    func play(currentSong song: MPChannelData.Song?, currentTimeChanged currentTime: CMTime) -> Void
    func play(cuurentSong song: MPChannelData.Song?, statusChanged status: PlayerManager.Status) -> Void
    func play(currentSong song: MPChannelData.Song?, withOccureError error: PlayerManager.PlayError) -> Void
    func play(songChanged song: MPChannelData.Song?) -> Void
}

extension PlayerDelegate {
    
    func play(currentSong song: MPChannelData.Song?, totalTimeChanged totalTime: CMTime?) -> Void {
        let center = NotificationCenter.default
        let userInfo: [String: Any] = ["song": song as Any, "value": totalTime as Any]
        center.post(name: Notification.Name.player.totalTimeChanged, object: nil, userInfo: userInfo)
    }
    
    func play(currentSong song: MPChannelData.Song?, currentTimeChanged currentTime: CMTime) -> Void {
        let center = NotificationCenter.default
        let userInfo: [String: Any] = ["song": song as Any, "value": currentTime as Any]
        center.post(name: Notification.Name.player.currentTimeChanged, object: nil, userInfo: userInfo)
    }
    
    func play(cuurentSong song: MPChannelData.Song?, statusChanged status: PlayerManager.Status) -> Void {
        let center = NotificationCenter.default
        let userInfo: [String: Any] = ["song": song as Any, "value": status as Any]
        center.post(name: Notification.Name.player.statusChanged, object: nil, userInfo: userInfo)
    }
    
    func play(currentSong song: MPChannelData.Song?, withOccureError error: PlayerManager.PlayError) -> Void {
        let center = NotificationCenter.default
        let userInfo: [String: Any] = ["song": song as Any, "value": error as Any]
        center.post(name: Notification.Name.player.errorOccurred, object: nil, userInfo: userInfo)
    }
    
    func play(songChanged song: MPChannelData.Song?) -> Void {
        let center = NotificationCenter.default
        let userInfo: [String: Any] = ["song": song as Any, "value": song as Any]
        center.post(name: Notification.Name.player.songChanged, object: nil, userInfo: userInfo)
    }

}
