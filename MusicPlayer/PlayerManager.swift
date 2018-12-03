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
    
    private(set) var player: AVQueuePlayer!
    private(set) var assets: [MPChannelData.Song]
    private(set) var currentIndex: Int?
    private(set) var status: Status {
        didSet {
            if player.currentItem != nil {
                status == .playing ? player.play() : player.pause()
            } else if status == .playing {
                playMedia()
                player.play()
            }
            if status == .playing {
                addTimeObserver()
            } else {
                clearTimeObserver()
            }
            delegate?.play(cuurentSong: assets[currentIndex!], statusChanged: status)
            
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
    private var totalTime: CMTime? {
        didSet {
            self.delegate?.play(currentSong: currentSong, totalTimeChanged: totalTime)
            if let endObserverToken = self.endObserverToken {
                player.removeTimeObserver(endObserverToken)
            }
            if let totalTime = totalTime {
                endObserverToken = player.addBoundaryTimeObserver(forTimes: [NSValue(time:totalTime)], queue: DispatchQueue.main, using: {
                    [unowned self] in
                    if self.delegate?.play(currentSong: self.currentSong!, playNextSongAtItemEnd: self.currentIndex!) ?? false {
                        // todo: 不删除当前item时，循环播放当前一首时，会出现bug，原因待查
                        self.player.remove(self.player.currentItem!)
                        self.next()
                    } else {
                        self.status = .sleep
                    }
                })
            } else {
                status = .sleep
            }
        }
    }
    
    init() {
        status = .sleep
        assets = []
        player = AVQueuePlayer(items: [])
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
    
    func inset(withSong song: MPChannelData.Song?, autoPlay: Bool = true) {
        guard let song = song, let src = song.mediaUrl else {
            return
        }
        if cache[src] == nil, let url = URL(string: src) {
            cache[src] = AVAsset(url: url)
        }
        remove(withSong: song)
        if autoPlay {
            assets.insert(song, at: 0)
            currentIndex = 0
            status = .playing
        } else {
            assets.append(song)
        }
    }
    
    func remove(withSong song : MPChannelData.Song) {
        let firstIndex = assets.firstIndex(of: song)
        assets.removeAll(where: { $0 == song })
        if let index = firstIndex, index < assets.count {
            currentIndex = (index + 1) % assets.count
        }
    }
    
    func play(withSong song: MPChannelData.Song) {
        inset(withSong: song)
        status = .playing
        playMedia()
    }
    
    func play() {
        status = .playing
    }
    
    func pause() {
        status = .sleep
    }
    
    func next() {
        if currentIndex == nil {
            currentIndex = 0
        } else {
            currentIndex = (currentIndex! + 1) % assets.count
        }
        playMedia()
        if let delegate = delegate, let currentIndex = currentIndex {
            delegate.play(songChanged: assets[currentIndex])
        }
    }
    
    func next(withPlay: Bool) {
        
    }
    
    func previous() {
        if currentIndex == nil {
            currentIndex = 0
        } else {
            currentIndex = (currentIndex! - 1 + assets.count) % assets.count
        }
        playMedia()
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
            let playerItem = AVPlayerItem(asset: asset)
            let currentItem = self.player.currentItem
            if self.player.canInsert(playerItem, after: currentItem) {
                self.player.insert(playerItem, after: currentItem)
                if currentItem != nil {
                    self.player.advanceToNextItem()
                }
            }
            self.totalTime = asset.duration
        }
    }
    
    private func playHandler(currentTime: CMTime) {
        if let currentSong = currentSong {
            delegate?.play(currentSong: currentSong, currentTimeChanged: currentTime)
        }
    }
}


extension PlayerManager {
    static let shared = PlayerManager()
    static let songChangedNotification = Notification.Name("PlayManager.songChanged")
}
