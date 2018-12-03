//
//  PlayrManager.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/26.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation
import AVFoundation

class PlayerManager {
    
    enum Status {
        case sleep
        case playing
    }
    
    enum PlayError: Error {
        case invalidIndex
        case notFoundAsset
        case canNotPlayable
        case loadFailed
    }
    
    internal weak var delegate: PlayerDelegate?
    
    private(set) var player: AVPlayer!
    private(set) var assets: [MPChannelData.Song]
    private(set) var currentIndex: Int?
    private(set) var status: Status {
        didSet {
            if status == .playing {
                addTimeObserver()
            } else {
                clearTimeObserver()
            }
            delegate?.play(cuurentSong: assets[currentIndex!], statusChanged: status)
            
        }
    }
    private(set) var totalTime: CMTime? {
        didSet {
            self.delegate?.play(currentSong: currentSong, totalTimeChanged: totalTime)
            if let endObserverToken = self.endObserverToken {
                player.removeTimeObserver(endObserverToken)
                self.endObserverToken = nil
            }
            if let totalTime = totalTime, totalTime > kCMTimeZero {
                endObserverToken = player.addBoundaryTimeObserver(forTimes: [NSValue(time:totalTime)], queue: DispatchQueue.main, using: {
                    [unowned self] in
                    if self.delegate?.play(currentSong: self.currentSong!, playNextSongAtItemEnd: self.currentIndex!) ?? false {
                        self.next()
                    } else {
                        self.pause()
                    }
                })
            }
        }
    }
    var currentSong: MPChannelData.Song? {
        get {
            guard let index = currentIndex else {
                return nil
            }
            return assets[index]
        }
    }

    private var cache: [String: AVAsset] = [:]
    private var interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(1000))
    private var timeObserverToken: Any?
    private var endObserverToken: Any?
    
    init() {
        status = .sleep
        assets = []
        player = AVPlayer()
    }
    
    deinit {
        if timeObserverToken != nil {
            player.removeTimeObserver(timeObserverToken!)
        }
        if let endObserverToken = self.endObserverToken {
            player.removeTimeObserver(endObserverToken)
        }
        player = nil
        for (key, _) in cache {
            cache[key] = nil
        }
    }
    
    func inset(withSong song: MPChannelData.Song?, atHead: Bool = true) {
        guard let song = song, let src = song.mediaUrl else {
            return
        }
        if cache[src] == nil, let url = URL(string: src) {
            cache[src] = AVAsset(url: url)
        }
        remove(withSong: song)
        if atHead {
            assets.insert(song, at: 0)
        } else {
            assets.append(song)
        }
    }
    
    func remove(withSong song : MPChannelData.Song) {
        assets.removeAll(where: { $0 == song })
    }
    
    func play(withSong song: MPChannelData.Song) {
        inset(withSong: song)
        currentIndex = 0
        playMedia()
    }
    
    func play() {
        guard status == .sleep else {
            return
        }
        if player.currentItem != nil {
            player.play()
            status = .playing
        } else {
            playMedia()
        }
    }
    
    func pause() {
        guard status == .playing else {
            return
        }
        player.pause()
        status = .sleep
    }
    
    func next() {
        if currentIndex == nil {
            currentIndex = 0
        } else {
            currentIndex = (currentIndex! + 1) % assets.count
        }
        resetPlayingSongState()
        if status == .playing {
            playMedia()
        }
        if let delegate = delegate, let currentIndex = currentIndex {
            delegate.play(songChanged: assets[currentIndex])
        }
    }
    
    func previous() {
        if currentIndex == nil {
            currentIndex = 0
        } else {
            currentIndex = (currentIndex! - 1 + assets.count) % assets.count
        }
        resetPlayingSongState()
        if status == .playing {
            playMedia()
        }
        if let delegate = delegate, let currentIndex = currentIndex {
            delegate.play(songChanged: assets[currentIndex])
        }
    }
    
    func seek(to time: Float, completionHandler handler: @escaping (_: Bool) -> Void) {
        let time = CMTime(seconds: Double(time), preferredTimescale: 1000)
        player.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: handler)
    }
    
    func addTimeObserver() {
        if timeObserverToken == nil {
            timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: {
                [unowned self] time in
                self.playHandler(currentTime: time)
            })
        }
    }
    
    func clearTimeObserver() {
        if timeObserverToken != nil {
            player.removeTimeObserver(timeObserverToken!)
            timeObserverToken = nil
        }
    }
    
    private func playMedia() {
        guard let index = currentIndex else {
            status = .sleep
            delegate?.play(currentSong: nil, withOccureError: PlayError.invalidIndex)
            return
        }
        guard let url = assets[index].mediaUrl, let asset = cache[url] else {
            status = .sleep
            delegate?.play(currentSong: currentSong!, withOccureError: PlayError.notFoundAsset)
            return
        }
        let requiredFileds: [String] = ["playable", "duration"]
        asset.loadValuesAsynchronously(forKeys: requiredFileds) {
            var error: NSError? = nil
            for filed in requiredFileds {
                let status = asset.statusOfValue(forKey: filed, error: &error)
                if status == AVKeyValueStatus.failed {
                    self.status = .sleep
                    self.delegate?.play(currentSong: self.currentSong, withOccureError: PlayError.loadFailed)
                    return
                }
            }
            if !asset.isPlayable {
                self.status = .sleep
                self.delegate?.play(currentSong: self.currentSong, withOccureError: PlayError.canNotPlayable)
                return
            }
            self.player.replaceCurrentItem(with: AVPlayerItem(asset: asset))
            self.totalTime = asset.duration
            self.player.play()
            self.status = .playing
        }
    }
    
    private func playHandler(currentTime: CMTime) {
        if let currentSong = currentSong {
            delegate?.play(currentSong: currentSong, currentTimeChanged: currentTime)
        }
    }
    
    private func resetPlayingSongState() {
        player.replaceCurrentItem(with: nil)
        playHandler(currentTime: kCMTimeZero)
        totalTime = kCMTimeZero
    }
}


extension PlayerManager {
    static let shared = PlayerManager()
}
