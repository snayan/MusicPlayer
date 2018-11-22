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
    
    lazy var paddingLeft: CGFloat = { frame.width * 0.08 }()
    lazy var paddingTop: CGFloat = { paddingLeft * 1.6 }()
    lazy var songImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.red
        return imageView
    }()
    lazy var songImageBackView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor(named: "themeLightColor")
        return view
    }()
    lazy var timeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.isContinuous = false
        slider.thumbTintColor = UIColor.clear
        slider.minimumTrackTintColor = UIColor(named: "themeColor")
        slider.maximumTrackTintColor = UIColor(named: "bgColor")
        return slider
    }()
    lazy var currentSongTime: UILabel = { createLabel(fontSize: 12, fontColor: timeSlider.minimumTrackTintColor) }()
    lazy var totalSongTime: UILabel = { createLabel(fontSize: 12, fontColor: timeSlider.maximumTrackTintColor) }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(songImageBackView)
        addSubview(songImageView)
        addSubview(timeSlider)
        addSubview(currentSongTime)
        addSubview(totalSongTime)
        makeConstraints()
        currentSongTime.text = String(timeSlider.minimumValue)
        totalSongTime.text = String(timeSlider.maximumValue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        songImageBackView.layer.cornerRadius = songImageBackView.frame.width/2
        songImageView.layer.cornerRadius = songImageView.frame.width/2
    }
    
    
    fileprivate func makeConstraints() {
        songImageBackView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(paddingTop)
            make.left.equalToSuperview().offset(paddingLeft)
            make.right.equalToSuperview().offset(-paddingLeft)
            make.height.equalTo(songImageView.snp.width)

        }
        songImageView.snp.makeConstraints{ make in
            make.edges.equalTo(songImageBackView).inset(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        }
        timeSlider.snp.makeConstraints{ make in
            make.top.equalTo(songImageBackView.snp.bottom).offset(paddingTop)
            make.left.right.equalTo(songImageBackView)
        }
        currentSongTime.snp.makeConstraints{ make in
            make.left.equalTo(timeSlider)
            make.top.equalTo(timeSlider.snp.bottom).offset(0)
        }
        totalSongTime.snp.makeConstraints{ make in
            make.right.equalTo(timeSlider)
            make.top.equalTo(currentSongTime)
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
