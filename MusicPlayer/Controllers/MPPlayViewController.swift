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
        observePlayerSongChanged()
        if let data = data, PlayerManager.shared.currentSong != data {
            PlayerManager.shared.inset(withSong: data, atHead: true)
            if autoPlay {
                PlayerManager.shared.play()
            }
        } else {
            restorePlayingInfo()
        }
    }

    
    fileprivate func updateContentifNeed() {
        song.text = data?.name
        backgroundImage.downloaded(from: data?.mediaPicture)
        contentView.singerPicture = data?.mediaPicture
        if let singerData = data?.singer, singerData.count > 0 {
            let fisrtSinger = singerData[0]
            singer.text = fisrtSinger.name
        }
        if data == nil {
            singer.text = nil
            contentView.timeSlider.isEnabled = false
            contentView.timeSlider.alpha = 0.4
            contentView.forwardBtn.isEnabled = false
            contentView.forwardBtn.alpha = 0.4
            contentView.rewardBtn.isEnabled = false
            contentView.rewardBtn.alpha = 0.4
            contentView.playBtn.isEnabled = false
            contentView.playBtn.alpha = 0.4
        }
    }
    
    fileprivate func restorePlayingInfo() {
        let status = PlayerManager.shared.status
        status == .playing ? contentView.startRotateImage() : contentView.stopRotateImage()
        contentView.playBtn.setBackgroundImage(UIImage(named: status == .playing ? "playIcon" : "pauseIcon")?.withRenderingMode(.alwaysTemplate), for: .normal);
        contentView.timeSlider.maximumValue = timeToFloat(time: PlayerManager.shared.totalTime)
        contentView.timeSlider.value = timeToFloat(time: PlayerManager.shared.player.currentTime())
        contentView.currentSongTime.text =  formartTime(time: contentView.timeSlider.value)
        contentView.totalSongTime.text = formartTime(time: timeToFloat(time: PlayerManager.shared.totalTime))
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

extension MPPlayContentViewController {
    
    func observePlayerSongChanged() {
        NotificationCenter.default.addObserver(self, selector: #selector(MPPlayContentViewController.playerSongChanged), name: Notification.Name.player.songChanged, object: nil)
    }
    
    @objc func playerSongChanged(notification: Notification) {
        let userInfo = notification.userInfo
        let song = userInfo?["value"] as? Song
        DispatchQueue.main.async {
            self.data = song
        }
    }
}
