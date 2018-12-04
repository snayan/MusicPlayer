//
//  PlayrManager.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/26.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation
import AVFoundation

typealias Song = MPChannelData.Song


struct SongQueue {
    var list: [Song]
    
    init(list: [Song]) {
        self.list = list
    }
    
    init(song: Song) {
        self.init(list: [song])
    }
    
    init() {
       self.init(list: [])
    }
    
    mutating func getNextSong() -> Song? {
        let song = popSong()
        appendSong(song)
        return song
    }
    
    mutating func getNextSong(withPrevious: Bool) -> Song? {
        if !withPrevious {
            return getNextSong()
        }
        guard list.count > 0 else {
            return nil
        }
        guard list.count > 1 else {
            return list[0]
        }
        
        unshiftSong(list.removeLast())
        unshiftSong(list.removeLast())
        
        return getNextSong()
    }
    
    mutating func popSong() -> Song? {
        return list.removeFirst()
    }
    
    mutating func appendSong(_ song: Song?) -> Void {
        guard let song = song else {
            return
        }
        list.append(song)
    }
    
    mutating func unshiftSong(_ song: Song?) -> Void {
        guard let song = song else {
            return
        }
        list.insert(song, at: 0)
    }
    
    mutating func clearList(by song: Song) -> Void {
        list.removeAll(where: { $0 == song })
    }
    
    mutating func clearList() -> Void {
        list.removeAll()
    }
}

class PlayerManager {
    
    internal var autoPlayNextAtSongEnd: Bool
    internal weak var delegate: PlayerDelegate?
    
    private(set) var player: AVPlayer
    private(set) var queue: SongQueue
    private(set) var currentSong: MPChannelData.Song? {
        didSet {
            delegate?.play(songChanged: currentSong)
            resetPlayingSongState()
            prepareMedia()
        }
    }
    private(set) var status: Status {
        didSet {
            if status == .playing {
                addTimeObserver()
            } else {
                clearTimeObserver()
            }
            delegate?.play(cuurentSong: currentSong, statusChanged: status)
            
        }
    }
    private(set) var totalTime: CMTime? {
        didSet {
            self.delegate?.play(currentSong: currentSong, totalTimeChanged: totalTime)
            self.clearEndObserver()
            self.addEndObserver()
        }
    }
    
    private var cache: [String: AVAsset] = [:]
    private var interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(1000))
    private var timeObserverToken: Any?
    private var endObserverToken: Any?
    
    init() {
        status = .sleep
        autoPlayNextAtSongEnd = true
        player = AVPlayer()
        queue = SongQueue()
    }
    
    deinit {
        clearTimeObserver()
        clearEndObserver()
        for (key, _) in cache {
            cache[key] = nil
        }
        queue.clearList()
    }
    
    func clearAssets() {
        queue.clearList()
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
            queue.unshiftSong(song)
        } else {
            queue.appendSong(song)
        }
    }
    
    func remove(withSong song : MPChannelData.Song) {
        queue.clearList(by: song)
    }
    
    func play(withSong song: MPChannelData.Song) {
        inset(withSong: song)
        currentSong = queue.getNextSong()
        status = .playing
    }
    
    func play() {
        guard status == .sleep else {
            return
        }
        status = .playing
        if currentSong != nil {
            player.play()
        } else {
            currentSong = queue.getNextSong()
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
        currentSong = queue.getNextSong()
    }
    
    func previous() {
        currentSong = queue.getNextSong(withPrevious: true)
    }
    
    func seek(to time: Float, completionHandler handler: @escaping (_: Bool) -> Void) {
        let time = CMTime(seconds: Double(time), preferredTimescale: 1000)
        player.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: handler)
    }
    
    private func addTimeObserver() {
        if timeObserverToken == nil {
            timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: {
                [unowned self] time in
                self.playHandler(currentTime: time)
            })
        }
    }
    
    private func clearTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    private func addEndObserver() {
        if let totalTime = totalTime, totalTime > kCMTimeZero, endObserverToken == nil {
            endObserverToken = player.addBoundaryTimeObserver(forTimes: [NSValue(time:totalTime)], queue: DispatchQueue.main, using: {
                [unowned self] in
                if self.autoPlayNextAtSongEnd {
                    self.next()
                } else {
                    self.pause()
                }
            })
        }
    }
    
    private func clearEndObserver() {
        if let endObserverToken = endObserverToken {
            player.removeTimeObserver(endObserverToken)
            self.endObserverToken = nil
        }
    }
    
    private func prepareMedia() {
        guard let currentSong = currentSong else {
            status = .sleep
            delegate?.play(currentSong: nil, withOccureError: PlayError.notFoundSong)
            return
        }
        guard let url = currentSong.mediaUrl, let asset = cache[url] else {
            status = .sleep
            delegate?.play(currentSong: currentSong, withOccureError: PlayError.notFoundAsset)
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
            if self.status == .playing {
                self.player.play()
            }
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
    
    enum Status {
        case sleep
        case playing
    }
    
    enum PlayError: Error {
        case notFoundSong
        case notFoundAsset
        case canNotPlayable
        case loadFailed
    }
    
    static let shared = PlayerManager()
}


