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
        if let data = data, PlayerManager.shared.currentSong != data {
            PlayerManager.shared.play(withSong: data)
        } else {
            restorePlayingInfo()
        }
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
    
    fileprivate func restorePlayingInfo() {
        let status = PlayerManager.shared.status
        status == .playing ? contentView.startRotateImage() : contentView.stopRotateImage()
        contentView.playBtn.setBackgroundImage(UIImage(named: status == .playing ? "playIcon" : "pauseIcon")?.withRenderingMode(.alwaysTemplate), for: .normal);
        contentView.timeSlider.maximumValue = contentView.timeToFloat(time: PlayerManager.shared.totalTime)
        contentView.timeSlider.value = contentView.timeToFloat(time: PlayerManager.shared.player.currentTime())
        contentView.currentSongTime.text =  contentView.formartTime(time: contentView.timeSlider.value)
        contentView.totalSongTime.text = contentView.formartTime(time: contentView.timeToFloat(time: PlayerManager.shared.totalTime))
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
    
    @objc fileprivate func tapDismiss() {
        dismiss(animated: true, completion: nil)
    }
}

extension MPPlayContentViewController: PlayerDelegate {
    
    func play(currentSong song: MPChannelData.Song?, totalTimeChanged totalTime: CMTime?) {
        self.contentView.play(currentSong: song, totalTimeChanged: totalTime)
    }
    
    func play(currentSong song: MPChannelData.Song?, currentTimeChanged currentTime: CMTime) {
        self.contentView.play(currentSong: song, currentTimeChanged: currentTime)
    }
    
    func play(cuurentSong song: MPChannelData.Song?, statusChanged status: PlayerManager.Status) {
        self.contentView.play(cuurentSong: song, statusChanged: status)
    }
    
    func play(currentSong song: MPChannelData.Song?, withOccureError error: PlayerManager.PlayError) {
        self.showPlayErrorAlter(error: error, buttonHandler: nil)
    }
    
    func play(songChanged song: MPChannelData.Song?) {
        DispatchQueue.main.async {
            self.data = song
        }
    }
    
}
