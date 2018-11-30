//
//  MPPlayViewController.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/17.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

class MPPlayViewController: UINavigationController {

    convenience init(data: MPChannelData.Song?, autoPlay: Bool = true) {
        self.init(rootViewController: MPPlayContentViewController(data: data, autoPlay: autoPlay))
        self.modalPresentationStyle = .overFullScreen
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor(named: "themeColor")
        navigationBar.tintColor = UIColor.white
    }

}

fileprivate class MPPlayContentViewController: UIViewController {
    
    var autoPlay: Bool
    var backgroundScale: Float = 1.2
    var playerItemContext = 0
    var data: MPChannelData.Song? {
        didSet {
            updateContentifNeed()
        }
    }

    lazy var song: UILabel = { createLabel(fontSize: 16, fontColor: UIColor.white) }()
    lazy var singer: UILabel = { createLabel(fontSize: 12, fontColor: UIColor.white) }()
    lazy var backgroundImage: UIImageView = UIImageView()
    
    lazy var titleView: UIView = { [unowned self] in
        let view = UIView()
        view.addSubview(song)
        view.addSubview(singer)
        view.backgroundColor = UIColor.red
        return view
        }()
    lazy var backgroundView: UIView = { [unowned self] in
        var view = UIView()
        view.backgroundColor = UIColor.clear
        view.frame = self.view.bounds
        
        // 设置backgroundImage
        let parentViewWidth = self.view.frame.width
        let parentViewHeight = self.view.frame.height
        let maxValue = max(parentViewWidth, parentViewHeight) * CGFloat(self.backgroundScale)
        backgroundImage.bounds.size = CGSize(width: maxValue, height: maxValue)
        backgroundImage.frame.origin = CGPoint(x: -(maxValue - parentViewWidth)/2, y: -(maxValue - parentViewHeight)/2)
        
        // 设置blur view
        var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(backgroundImage, at: 0)
        view.addSubview(blurEffectView)
        return view
    }()
    lazy var contentView: MPPlayContentView = { [unowned self] in MPPlayContentView(frame: self.view.bounds) }()
    
    init(data: MPChannelData.Song?, autoPlay: Bool) {
        self.autoPlay = autoPlay
        self.data = data
        super.init(nibName: nil, bundle: nil)
        navigationItem.titleView = titleView
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(tapDismiss))
        PlayerManager.shared.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
        view.addSubview(contentView)
        view.insertSubview(backgroundView, belowSubview: contentView)
        makeConstriants()
        updateContentifNeed()
        PlayerManager.shared.inset(withSong: data, autoPlay: autoPlay)
    }

    
    fileprivate func updateContentifNeed() {
        guard let songData = data else {
            return
        }
        song.text = songData.name
        if let singerData = songData.singer, singerData.count > 0 {
            let fisrtSinger = singerData[0]
            singer.text = fisrtSinger.name
            backgroundImage.downloaded(from: fisrtSinger.picture)
            contentView.singerPicture = fisrtSinger.picture
        }
    }
    
    fileprivate func createLabel(fontSize size: Float, fontColor color: UIColor) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(size))
        label.textColor = color
        label.numberOfLines = 1
        label.sizeToFit()
        label.textAlignment = .center
        label.baselineAdjustment = .alignBaselines
        return label
    }
    
    fileprivate func makeConstriants() {
        song.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-6)
            make.width.equalToSuperview().multipliedBy(0.6)
        }
        singer.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.top.equalTo(song.snp.bottom)
        }
    }
    
    fileprivate func formartTime(time: Int?) -> String {
        guard let time = time else {
            return "00:00"
        }
        let munite = time / 60
        let second = time - munite * 60
        let muniteString = munite < 10 ? "0\(munite)" : "\(munite)"
        let secondString = second < 10 ? "0\(second)" : "\(second)"
        return muniteString + ":" + secondString
    }
    
    @objc fileprivate func tapDismiss() {
        dismiss(animated: true, completion: nil)
    }
}


extension MPPlayContentViewController: PlayerDelegate {
    func play(currentSong song: MPChannelData.Song, totalTimeChanged totalTime: Int) {
        DispatchQueue.main.async {
            self.contentView.timeSlider.maximumValue = Float(totalTime)
            self.contentView.totalSongTime.text = self.formartTime(time: totalTime)
        }
    }
    
    func play(currentSong song: MPChannelData.Song, currentTimeChaned currentTime: Int) {
        DispatchQueue.main.async {
            self.contentView.timeSlider.value = Float(currentTime)
            self.contentView.currentSongTime.text = self.formartTime(time: currentTime)
        }
    }
    
    func play(cuurentSong song: MPChannelData.Song, statusChanged status: PlayerManager.Status) {
        DispatchQueue.main.async {
            self.contentView.playBtn.setBackgroundImage(UIImage(named: status == .playing ? "playIcon" : "pauseIcon")?.withRenderingMode(.alwaysTemplate), for: .normal);
            status == .playing ? self.contentView.startRotateImage() : self.contentView.stopRotateImage()
        }
    }
    
    func play(currentSong song: MPChannelData.Song, withOccureError error: PlayerManager.PlayError) {
        
    }
    
    func play(songChanged song: MPChannelData.Song) {
        DispatchQueue.main.async {
            self.data = song
        }
    }
    
}
