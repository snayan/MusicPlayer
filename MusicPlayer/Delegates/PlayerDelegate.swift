//
//  PlayerDelegate.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/27.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation

protocol PlayerDelegate: class{
    func play(currentSong song: MPChannelData.Song, totalTimeChanged totalTime: Int) -> Void
    func play(currentSong song: MPChannelData.Song, currentTimeChaned currentTime: Int) -> Void
    func play(cuurentSong song: MPChannelData.Song, statusChanged status: PlayerManager.Status) -> Void
    func play(currentSong song: MPChannelData.Song, withOccureError error: PlayerManager.PlayError) -> Void
    func play(currentSong song: MPChannelData.Song, autoPlayNextSongWhenTimeEnd time: Int) -> Bool
    func play(songChanged song: MPChannelData.Song) -> Void
    func play(autoPlayFirstSongWhenLastEnd song: MPChannelData.Song) -> Bool
}

extension PlayerDelegate {
    func play(currentSong song: MPChannelData.Song, autoPlayNextSongWhenTimeEnd time: Int) -> Bool {
        return true
    }
    func play(autoPlayFirstSongWhenLastEnd song: MPChannelData.Song) -> Bool {
        return true
    }
}
