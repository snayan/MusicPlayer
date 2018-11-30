//
//  MPPlayContentView.swift
//  MusicPlayer
//
//  Created by yang.zhang on 2018/11/19.
//  Copyright © 2018 yang.zhang. All rights reserved.
//

import UIKit
import SnapKit

class MPPlayContentView: UIView {
    
    var singerPicture: String? {
        didSet {
            songImageView.downloaded(from: singerPicture, useFallImage: UIImage(named: "defaultSongPic"))
        }
    }
    
    lazy var rotateKey: String = "rotateImage"
    lazy var paddingLeft: CGFloat = { frame.width * 0.08 }()
    lazy var paddingTop: CGFloat = { paddingLeft * 1.6 }()
    lazy var songImageView: UIImageView = { [unowned self] in
        let view = UIImageView(image: UIImage(named: "defaultSongPic"))
        view.layer.borderColor = UIColor(named: "themeLightColor")?.cgColor
        view.layer.borderWidth = 8
        view.clipsToBounds = true
        return view
    }()
    lazy var timeSlider: UISlider = { [unowned self] in
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 0
        slider.isContinuous = false
        slider.thumbTintColor = UIColor.clear
        slider.minimumTrackTintColor = UIColor(named: "themeColor")
        slider.maximumTrackTintColor = UIColor(named: "bgColor")
        return slider
    }()
    lazy var forwardBtn: UIButton = { [unowned self] in
        let btn = UIButton(type: UIButtonType.system)
        btn.tintColor = UIColor(named: "themeLightColor")
        btn.setBackgroundImage(UIImage(named: "forwardIcon")?.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(MPPlayContentView.forward), for: .touchUpInside)
        return btn
    }()
    lazy var rewardBtn: UIButton = { [unowned self] in
        let btn = UIButton(type: UIButtonType.system)
        btn.tintColor = UIColor(named: "themeLightColor")
        btn.setBackgroundImage(UIImage(named: "rewindIcon")?.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(MPPlayContentView.rewind), for: .touchUpInside)
        return btn
    }()
    lazy var playBtn: UIButton = { [unowned self] in
        let btn = UIButton(type: UIButtonType.system)
        btn.tintColor = UIColor(named: "themeLightColor")
        btn.setBackgroundImage(UIImage(named: "pauseIcon")?.withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(MPPlayContentView.togglePlay), for: .touchUpInside)
        return btn
    }()
    lazy var currentSongTime: UILabel = { createLabel(fontSize: 12, fontColor: timeSlider.minimumTrackTintColor) }()
    lazy var totalSongTime: UILabel = { createLabel(fontSize: 12, fontColor: timeSlider.maximumTrackTintColor) }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(songImageView)
        addSubview(timeSlider)
        addSubview(currentSongTime)
        addSubview(totalSongTime)
        addSubview(forwardBtn)
        addSubview(rewardBtn)
        addSubview(playBtn)
        makeConstraints()
        currentSongTime.text = String(timeSlider.minimumValue)
        totalSongTime.text = String(timeSlider.maximumValue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        songImageView.layer.cornerRadius = songImageView.frame.height/2
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
    
    func startRotateImage() {
        if songImageView.layer.animation(forKey: rotateKey) == nil {
            let animate = CABasicAnimation(keyPath: "transform.rotation")
            animate.duration = 80
            animate.repeatCount = Float.infinity
            animate.fromValue = 0.0
            animate.toValue = CGFloat.pi * 2
            songImageView.layer.add(animate, forKey: rotateKey)
        }
    }
    
    func stopRotateImage() {
        if songImageView.layer.animation(forKey: rotateKey) != nil {
            songImageView.layer.removeAnimation(forKey: rotateKey)
        }
    }
    
    fileprivate func makeConstraints() {
        songImageView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(paddingTop)
            make.left.equalToSuperview().offset(paddingLeft)
            make.right.equalToSuperview().offset(-paddingLeft)
            make.height.equalTo(songImageView.snp.width)

        }
        timeSlider.snp.makeConstraints{ make in
            make.top.equalTo(songImageView.snp.bottom).offset(paddingTop)
            make.left.right.equalTo(songImageView)
        }
        currentSongTime.snp.makeConstraints{ make in
            make.left.equalTo(timeSlider)
            make.top.equalTo(timeSlider.snp.bottom).offset(0)
        }
        totalSongTime.snp.makeConstraints{ make in
            make.right.equalTo(timeSlider)
            make.top.equalTo(currentSongTime)
        }
        playBtn.snp.makeConstraints{ make in
            make.top.equalTo(timeSlider.snp.bottom).offset(paddingTop)
            make.centerX.equalTo(timeSlider)
            make.width.equalTo(34)
            make.height.equalTo(38)
        }
        rewardBtn.snp.makeConstraints{ make in
            make.centerY.equalTo(playBtn)
            make.right.equalTo(playBtn.snp.left).offset(-60)
            make.width.equalTo(34)
            make.height.equalTo(31 * 34 / 48)
        }
        forwardBtn.snp.makeConstraints{ make in
            make.centerY.equalTo(playBtn)
            make.left.equalTo(playBtn.snp.right).offset(60)
            make.width.equalTo(rewardBtn)
            make.height.equalTo(rewardBtn)
        }
    }
    
    fileprivate func createLabel(fontSize size: Float, fontColor color: UIColor?) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(size))
        label.textColor = color
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }
    
}
