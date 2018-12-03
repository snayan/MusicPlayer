//
//  MPPlayContentView.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/19.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

class MPPlayContentView: UIView {
    
    var singerPicture: String? {
        didSet {
            songImageView.downloaded(from: singerPicture, useFallImage: UIImage(named: "defaultSongPic"))
        }
    }
    private var isSeeking: Bool = false
    private var animator: UIViewPropertyAnimator?
    lazy var paddingLeft: CGFloat = { frame.width * 0.08 }()
    lazy var paddingTop: CGFloat = { paddingLeft * 1.6 }()
    lazy var contentWidth: CGFloat = { frame.width - paddingLeft * 2 }()
    lazy var songImageView: UIImageView = { [unowned self] in
        let view = UIImageView(image: UIImage(named: "defaultSongPic"))
        view.frame = CGRect(x: paddingLeft, y: paddingTop, width: contentWidth, height: contentWidth)
        view.layer.cornerRadius = contentWidth / 2
        view.layer.borderWidth = 8
        view.layer.borderColor = UIColor(named: "themeLightColor")?.cgColor
        view.clipsToBounds = true
        return view
    }()
    lazy var timeSlider: UISlider = { [unowned self] in
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 0
        slider.isContinuous = false
        slider.thumbTintColor = UIColor.clear
        slider.isUserInteractionEnabled = true
        slider.minimumTrackTintColor = UIColor(named: "themeColor")
        slider.maximumTrackTintColor = UIColor(named: "bgColor")
        slider.frame = CGRect(x: paddingLeft, y: songImageView.frame.maxY + paddingTop, width: contentWidth, height: 10)
        slider.addTarget(self, action: #selector(MPPlayContentView.seekSongTime), for: UIControlEvents.valueChanged)
        slider.addTarget(self, action: #selector(MPPlayContentView.startSeekSong), for: UIControlEvents.touchDragInside)
        return slider
    }()
    lazy var forwardBtn: UIButton = { [unowned self] in
        let btn = UIButton(type: UIButtonType.system)
        let width: CGFloat = 34
        let height: CGFloat = 31 * 34 / 48
        btn.frame = CGRect(x: playBtn.frame.maxX + 60, y: playBtn.frame.minY + playBtn.frame.height/2 - height/2, width: 34, height: 31 * 34 / 48)
        btn.tintColor = UIColor(named: "themeLightColor")
        btn.setBackgroundImage(UIImage(named: "forwardIcon")?.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(MPPlayContentView.forward), for: .touchUpInside)
        return btn
    }()
    lazy var rewardBtn: UIButton = { [unowned self] in
        let btn = UIButton(type: UIButtonType.system)
        let width: CGFloat = 34
        let height: CGFloat = 31 * 34 / 48
        btn.frame = CGRect(x: playBtn.frame.minX - width - 60, y: playBtn.frame.minY + playBtn.frame.height/2 - height/2, width: 34, height: 31 * 34 / 48)
        btn.tintColor = UIColor(named: "themeLightColor")
        btn.setBackgroundImage(UIImage(named: "rewindIcon")?.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(MPPlayContentView.rewind), for: .touchUpInside)
        return btn
    }()
    lazy var playBtn: UIButton = { [unowned self] in
        let btn = UIButton(type: UIButtonType.system)
        btn.frame = CGRect(x: (frame.width - 34 ) / 2, y: currentSongTime.frame.maxY + paddingTop - 19, width: 34, height: 38)
        btn.tintColor = UIColor(named: "themeLightColor")
        btn.setBackgroundImage(UIImage(named: "pauseIcon")?.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(MPPlayContentView.togglePlay), for: .touchUpInside)
        return btn
    }()
    lazy var currentSongTime: UILabel = {
        let label = createLabel(fontSize: 12, fontColor: timeSlider.minimumTrackTintColor)
        label.frame = CGRect(x: paddingLeft, y: timeSlider.frame.maxY + 10, width: contentWidth/2, height: 20)
        label.text = "00:00"
        return label
    }()
    lazy var totalSongTime: UILabel = {
        let label = createLabel(fontSize: 12, fontColor: timeSlider.maximumTrackTintColor)
        label.frame = CGRect(x: currentSongTime.frame.maxX, y: currentSongTime.frame.minY, width: contentWidth/2, height: 20)
        label.textAlignment = .right
        label.text = "00:00"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(songImageView)
        addSubview(timeSlider)
        addSubview(currentSongTime)
        addSubview(totalSongTime)
        addSubview(forwardBtn)
        addSubview(rewardBtn)
        addSubview(playBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func togglePlay() {
        if PlayerManager.shared.status == .playing {
            PlayerManager.shared.pause()
        } else {
            PlayerManager.shared.play()
        }
    }
    
    @objc fileprivate func forward() {
        PlayerManager.shared.next()
    }
    
    @objc fileprivate func rewind() {
        PlayerManager.shared.previous()
    }
    
    @objc fileprivate func seekSongTime() {
        PlayerManager.shared.seek(to: timeSlider.value, completionHandler: {
            [unowned self] success in
            self.isSeeking = !success
        })
    }
    
    @objc fileprivate func startSeekSong() {
        self.isSeeking = true
        self.currentSongTime.text = self.formartTime(time: timeSlider.value)
    }
    
    func startRotateImage() {
        if animator == nil {
            animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 40, delay: 0, options: .curveLinear, animations: {
                self.songImageView.transform = self.songImageView.transform.rotated(by: CGFloat.pi)
            }, completion: { finalPosition in
                self.animator = nil
                self.startRotateImage()
            })
        } else {
            animator!.startAnimation()
        }
        
    }
    
    func stopRotateImage() {
        animator?.pauseAnimation()
    }
    
    fileprivate func angleToRadian(angle: Int) -> CGFloat {
        return CGFloat.pi * CGFloat((angle % 360)) / 180
    }
    
    
    fileprivate func createLabel(fontSize size: Float, fontColor color: UIColor?) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(size))
        label.textColor = color
        label.numberOfLines = 1
        label.bounds = CGRect(x: 0, y: 0, width: 40, height: 20)
        label.sizeToFit()
        return label
    }
    
    fileprivate func timeToFloat(time: CMTime) -> Float {
        return Float(CMTimeGetSeconds(time))
    }
    
    fileprivate func formartTime(time: Float?) -> String {
        guard let time = time else {
            return "00:00"
        }
        let intTime = Int(time)
        let munite = intTime / 60
        let second = intTime - munite * 60
        let muniteString = munite < 10 ? "0\(munite)" : "\(munite)"
        let secondString = second < 10 ? "0\(second)" : "\(second)"
        return muniteString + ":" + secondString
    }
    
}

extension MPPlayContentView: PlayerDelegate {
    
    func play(currentSong song: MPChannelData.Song?, totalTimeChanged totalTime: CMTime?) {
        DispatchQueue.main.async {
            let maximumValue: Float = totalTime == nil ? 0 : self.timeToFloat(time: totalTime!)
            self.timeSlider.maximumValue = maximumValue
            self.totalSongTime.text = self.formartTime(time: maximumValue)
        }
    }
    
    func play(currentSong song: MPChannelData.Song, currentTimeChanged currentTime: CMTime) {
        DispatchQueue.main.async {
            if !self.isSeeking {
                let value = self.timeToFloat(time: currentTime)
                self.currentSongTime.text = self.formartTime(time: value)
                self.timeSlider.value = value
            }
        }
    }
    
    func play(cuurentSong song: MPChannelData.Song, statusChanged status: PlayerManager.Status) {
        DispatchQueue.main.async {
            self.playBtn.setBackgroundImage(UIImage(named: status == .playing ? "playIcon" : "pauseIcon")?.withRenderingMode(.alwaysTemplate), for: .normal);
            status == .playing ? self.startRotateImage() : self.stopRotateImage()
        }
    }
    
}
