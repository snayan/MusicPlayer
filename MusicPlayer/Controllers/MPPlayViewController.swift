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

    convenience init(data: MPChannelData.Song?) {
        self.init(rootViewController: MPPlayContentViewController(data: data))
        self.modalPresentationStyle = .overFullScreen
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor(named: "themeColor")
        navigationBar.tintColor = UIColor.white
    }

}

fileprivate class MPPlayContentViewController: UIViewController {
    
    var data: MPChannelData.Song?
    var backgroundScale: Float = 1.2
    var playerItemContext = 0

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
    
    var player: AVPlayer = AVPlayer()
    
    init(data: MPChannelData.Song?) {
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
        setup()
        prepareForPlay(src: data?.mediaUrl)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItemStatus
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            // Switch over status value
            switch status {
            case .readyToPlay:
            // Player item is ready to play.
                debugPrint(player.currentItem?.duration.value)
                player.play()
            case .failed:
            // Player item failed. See error.
                debugPrint("failed\(status.rawValue)")
            case .unknown:
                // Player item is not yet ready.
                debugPrint("unknown\(status.rawValue)")
            }
        }
    }
    
    fileprivate func setup() {
        song.text = data?.name
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
    
    fileprivate func prepareForPlay(src: String?) {
        if let validSrc = src, let url = URL(string: validSrc) {
            let asset = AVAsset(url: url)
            asset.loadValuesAsynchronously(forKeys: ["playable"]) {
                var error: NSError? = nil
                let status = asset.statusOfValue(forKey: "playable", error: &error)
                switch status {
                    case .loaded:
                        if asset.isPlayable {
                            let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
                            playerItem.addObserver(self,
                                                   forKeyPath: #keyPath(AVPlayerItem.status),
                                                   options: [.old, .new],
                                                   context: &self.playerItemContext)
                            self.player.replaceCurrentItem(with: playerItem)
                        }
                    case .failed:
                    // Handle error
                        fatalError(error.debugDescription)
                    default:
                        // Handle all other cases
                        debugPrint("加载中")
                }
            }
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
    
    @objc fileprivate func tapDismiss() {
        dismiss(animated: true, completion: nil)
    }
}
