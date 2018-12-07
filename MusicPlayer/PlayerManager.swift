//
//  PlayrManager.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/26.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import Foundation
import MediaPlayer
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
        guard list.count > 0 else {
            return nil
        }
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

class PlayerManager: NSObject, PlayerDelegate {
    
    internal var autoPlayNextAtSongEnd: Bool
    internal weak var delegate: PlayerDelegate?
    
    private(set) var player: AVPlayer
    private(set) var queue: SongQueue
    private(set) var currentSong: MPChannelData.Song? {
        didSet {
            delegate?.play(self, songChanged: currentSong)
            resetPlayingSongState()
            prepareMedia()
            updateNowPlayingInfoCenter()
        }
    }
    private(set) var status: Status {
        didSet {
            if status == .playing {
                addTimeObserver()
                if !hasActive {
                    do {
                        try AVAudioSession.sharedInstance().setActive(true)
                        hasActive = true
                    } catch {
                        hasActive = false
                    }
                }
            } else {
                clearTimeObserver()
            }
            delegate?.play(self, statusChanged: status)
            
        }
    }
    private(set) var totalTime: CMTime? {
        didSet {
            self.delegate?.play(self, totalTimeChanged: totalTime)
            self.clearEndObserver()
            self.addEndObserver()
        }
    }
    
    private var hasActive: Bool = false
    private var cache: [String: AVAsset] = [:]
    private var interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(1000))
    private var timeObserverToken: Any?
    private var endObserverToken: Any?
    private var playerStatusContext = 1
    
    override init() {
        status = .sleep
        autoPlayNextAtSongEnd = true
        player = AVPlayer()
        queue = SongQueue()
        super.init()
        delegate = self
        setupRemoteTransportControls()
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.old, .new], context: &playerStatusContext)
    }
    
    deinit {
        clearTimeObserver()
        clearEndObserver()
        for (key, _) in cache {
            cache[key] = nil
        }
        queue.clearList()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &playerStatusContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if keyPath == #keyPath(AVPlayer.status) {
            let status: AVPlayer.Status
            if let statusNumber = change?[NSKeyValueChangeKey.newKey] as? Int {
                status = AVPlayer.Status(rawValue: statusNumber)!
            } else {
                status = .unknown
            }
            if status == .failed {
                // 必须重新创建player
                delegate?.play(self, withOccureError: .playerError)
                player = AVPlayer()
            }
        }
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
        player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: handler)
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
        if let totalTime = totalTime, totalTime > CMTime.zero, endObserverToken == nil {
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
            delegate?.play(self, withOccureError: .notFoundSong)
            return
        }
        guard let url = currentSong.mediaUrl, let asset = cache[url] else {
            delegate?.play(self, withOccureError: .notFoundAsset)
            return
        }
        let requiredFileds: [String] = ["playable", "duration"]
        asset.loadValuesAsynchronously(forKeys: requiredFileds) {
            var error: NSError? = nil
            for filed in requiredFileds {
                let status = asset.statusOfValue(forKey: filed, error: &error)
                if status == AVKeyValueStatus.failed {
                    self.delegate?.play(self, withOccureError: .loadFailed)
                    return
                }
            }
            if !asset.isPlayable {
                self.delegate?.play(self, withOccureError: .canNotPlayable)
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
        delegate?.play(self, currentTimeChanged: currentTime)
    }
    
    private func resetPlayingSongState() {
        player.currentItem?.asset.cancelLoading()
        player.currentItem?.cancelPendingSeeks()
        player.cancelPendingPrerolls()
        player.replaceCurrentItem(with: nil)
        playHandler(currentTime: CMTime.zero)
        totalTime = CMTime.zero
    }
}

extension PlayerManager {
    
    enum Status {
        case sleep
        case playing
    }
    
    enum PlayError: String, Error {
        case notFoundSong
        case notFoundAsset
        case canNotPlayable
        case loadFailed
        case playerError
    }
    
    static let shared = PlayerManager()
}

extension PlayerManager {
    
    private func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    @objc private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        if type == .began {
            // Interruption began, take appropriate actions (save state, update user interface)
            pause()
            hasActive = false
        } else if type == .ended {
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                    return
            }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // Interruption Ended - playback should resume
                play()
            }
        }
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
                return
        }
        switch reason {
            case .newDeviceAvailable:
                let session = AVAudioSession.sharedInstance()
                for output in session.currentRoute.outputs where output.portType == AVAudioSession.Port.headphones {
                    // 耳机连接
                    break
                }
            case .oldDeviceUnavailable:
                if let previousRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                    for output in previousRoute.outputs where output.portType == AVAudioSession.Port.headphones {
                        pause()
                        break
                    }
                }
            default: ()
        }
    }
}

extension PlayerManager {
    
    private func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.isEnabled = true
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.isEnabled = true
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] _ in
            if self.currentSong == nil {
                return .noActionableNowPlayingItem
            } else if self.status == .playing {
                return .commandFailed
            } else {
                self.play()
                return .success
            }
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] _ in
            if self.currentSong == nil {
                return .noActionableNowPlayingItem
            } else if self.status == .sleep {
                return .commandFailed
            } else {
                self.pause()
                return .success
            }
        }
        
        commandCenter.nextTrackCommand.addTarget { [unowned self] _ in
            self.next()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [unowned self] _ in
            self.previous()
            return .success
        }
    }
    
    private func updateNowPlayingInfoCenter(artwork: UIImage? = nil, hasFetch: Bool = false) {
        guard let currentSong = currentSong else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }
        var singer: MPChannelData.Singer?
        if let singers = currentSong.singer, singers.count > 0 {
            singer = singers[0]
        }
        if artwork == nil, hasFetch == false, let picture = currentSong.mediaPicture, let url = URL.ATS(string: picture) {
            MPBaseURLSession.getImage(withUrl: url, completionHandler: { [unowned self] image, error in
                self.updateNowPlayingInfoCenter(artwork: image, hasFetch: true)
            })
            return
        }
        var nowPlayingInfo: [String: Any] = [:]
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackQueueCount] = queue.list.count
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentItem?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.currentItem?.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = currentSong.album?.title
        nowPlayingInfo[MPMediaItemPropertyAlbumArtist] = singer?.name
        nowPlayingInfo[MPMediaItemPropertyArtist] = singer?.title
        nowPlayingInfo[MPMediaItemPropertyAssetURL] = currentSong.mediaUrl != nil ? URL(string: currentSong.mediaUrl!) : nil
        nowPlayingInfo[MPMediaItemPropertyIsCloudItem] = false
        nowPlayingInfo[MPMediaItemPropertyTitle] = currentSong.title
        if let artwork = artwork {
            let itemArtwork = MPMediaItemArtwork(boundsSize: artwork.size, requestHandler: {
                (size) -> UIImage in
                return artwork
            })
            nowPlayingInfo[MPMediaItemPropertyArtwork] = itemArtwork
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
}

