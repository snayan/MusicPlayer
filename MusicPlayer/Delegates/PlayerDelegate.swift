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
    
    func play(songChanged song: MPChannelData.Song?) -> Void {
        
    }
    
    func play(currentSong song: MPChannelData.Song?, withOccureError error: PlayerManager.PlayError) -> Void {
        
    }
}
