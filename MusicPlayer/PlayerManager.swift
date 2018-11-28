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
        case notFoundAsset
        case canNotPlayable
        case loadFailed
    }
    
    static let shared = PlayerManager()
    
    internal weak var delegate: PlayerDelegate?
    
    private(set) var player: AVQueuePlayer!
    private(set) var assets: [MPChannelData.Song] {
        didSet {
//            let items: [AVAsset] = assets.map() { src in
//                if let asset = cache[src] {
//                    return asset
//                }
//                return AVAsset(url: URL(string: src)!)
//            }
//            player = AVQueuePlayer(items: items.map{ AVPlayerItem(asset: $0) })
//            if status == .playing {
//                play(completionHandler: handler)
//            }
        }
    }
    private(set) var currentIndex: Int?
    private(set) var status: Status {
        didSet {
            if player.currentItem != nil {
                status == .playing ? player.play() : player.pause()
            } else if status == .playing {
                playMedia()
                player.play()
            }
            delegate?.play(cuurentSong: assets[currentIndex!], statusChanged: status)
        }
    }

    private var cache: [String: AVAsset] = [:]
    private var interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    private var timeObserverToken: Any?
    private var totalTime: Int? {
        didSet {
            self.delegate?.play(currentSong: assets[currentIndex ?? 0], totalTimeChanged: totalTime ?? 0)
        }
    }
    
    init() {
        status = .sleep
        assets = []
        player = AVQueuePlayer(items: [])
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: {
            [unowned self] time in
            self.playHandler(currentTime: Int(CMTimeGetSeconds(time)))
        })
    }
    
    deinit {
        if timeObserverToken != nil {
            player.removeTimeObserver(timeObserverToken!)
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
            playMedia()
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
    
    private func playMedia() {
        let current = currentIndex ?? 0
        guard let url = assets[current].mediaUrl, let asset = cache[url] else {
            status = .sleep
            delegate?.play(currentSong: assets[current], withOccureError: PlayError.notFoundAsset)
            return
        }
        let requiredFileds: [String] = ["playable", "duration"]
        asset.loadValuesAsynchronously(forKeys: requiredFileds) {
            var error: NSError? = nil
            for filed in requiredFileds {
                let status = asset.statusOfValue(forKey: filed, error: &error)
                if status == AVKeyValueStatus.failed {
                    self.status = .sleep
                    self.delegate?.play(currentSong: self.assets[current], withOccureError: PlayError.loadFailed)
                    return
                }
            }
            if !asset.isPlayable {
                self.status = .sleep
                self.delegate?.play(currentSong: self.assets[current], withOccureError: PlayError.canNotPlayable)
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
            self.totalTime = Int(CMTimeGetSeconds(asset.duration))
        }
    }
    
    private func playHandler(currentTime: Int) {
        if let delegate = delegate, let currentIndex = currentIndex {
            if currentTime == totalTime, currentIndex == assets.count - 1, delegate.play(autoPlayFirstSongWhenLastEnd: assets[currentIndex]) {
                next()
            } else if currentTime == totalTime, delegate.play(currentSong: assets[currentIndex], autoPlayNextSongWhenTimeEnd: currentTime) {
                next()
            }
            delegate.play(currentSong: assets[currentIndex], currentTimeChaned: currentTime)
        }
    }
}
